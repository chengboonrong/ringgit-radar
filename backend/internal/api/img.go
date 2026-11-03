package api

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"image"
	"image/jpeg"
	_ "image/png"
	"io"
	"log/slog"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	"github.com/go-chi/chi/v5"
	"golang.org/x/image/draw"
	"golang.org/x/sync/singleflight"
)

// a Vercel function's response may not exceed 4.5 MB; stay well under it
const maxResponseBytes = 4_000_000

// the image behind a hash never changes, so browsers and CDNs may keep it for good. Only a 200 gets this.
const imageCacheControl = "public, max-age=31536000, s-maxage=31536000, immutable"

const (
	DefaultImageUpstream = "https://img-eshop.cdn.nintendo.net/i/"
	// DefaultUpstreamPerHour is how many images the proxy fetches from the source in an hour: 10 a minute.
	DefaultUpstreamPerHour = 600
	maxUpstreamFetches     = 4
	defaultWidth           = 640
	maxImageBytes          = 16 << 20
)

var (
	hashRE       = regexp.MustCompile(`^[0-9a-f]{64}$`)
	allowedWidth = map[int]bool{320: true, 640: true, 1280: true}

	errNotFound = errors.New("image not found upstream")
	errTooLarge = errors.New("image does not fit in a function response")
	errBlocked  = errors.New("image source refused us; not asking again until restart")
	errBudget   = errors.New("image fetch budget for this hour is used up")
)

// ImageProxy serves resized copies of catalogue art. Only a valid hash and an allowed width ever
// reach upstream, as https://.../i/<hash>.jpg with no query string. Originals and resized copies are
// cached on disk, nothing is pre-fetched, and a 401/403 stops all further upstream requests.
type ImageProxy struct {
	Dir       string
	Upstream  string // base URL ending in "/"
	HTTP      *http.Client
	UserAgent string
	Log       *slog.Logger

	// UpstreamPerHour caps fetches from the source in each hour, whoever asks; cached images never count.
	// Over the cap the proxy answers 503 and does not try again. Zero or less means no cap.
	UpstreamPerHour int

	now     func() time.Time
	sem     chan struct{}
	group   singleflight.Group
	blocked atomic.Bool
	mu      sync.Mutex
	hour    time.Time // when the current hour of the budget began
	used    int
}

func NewImageProxy(dir, userAgent string, log *slog.Logger) *ImageProxy {
	return &ImageProxy{
		Dir: dir, Upstream: DefaultImageUpstream, HTTP: &http.Client{Timeout: 30 * time.Second},
		UserAgent: userAgent, Log: log, sem: make(chan struct{}, maxUpstreamFetches),
		UpstreamPerHour: DefaultUpstreamPerHour, now: time.Now,
	}
}

func (p *ImageProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	hash := chi.URLParam(r, "hash")
	if !hashRE.MatchString(hash) {
		writeErr(w, http.StatusBadRequest, "bad image hash")
		return
	}
	width := defaultWidth
	if raw := r.URL.Query().Get("w"); raw != "" {
		n, err := strconv.Atoi(raw)
		if err != nil || !allowedWidth[n] {
			writeErr(w, http.StatusBadRequest, "w must be 320, 640 or 1280")
			return
		}
		width = n
	}
	if p.Dir == "" {
		p.serveFromMemory(w, r, hash, width)
		return
	}
	path := filepath.Join(p.Dir, fmt.Sprintf("%s_%d.jpg", hash, width))
	f, err := os.Open(path)
	if errors.Is(err, os.ErrNotExist) {
		// Detached from the request so one client giving up does not fail the others waiting on it.
		_, err, _ = p.group.Do(path, func() (any, error) {
			ctx, cancel := context.WithTimeout(context.WithoutCancel(r.Context()), 45*time.Second)
			defer cancel()
			return nil, p.build(ctx, hash, width, path)
		})
		if err == nil {
			f, err = os.Open(path)
		}
	}
	if err != nil {
		p.fail(w, hash, err)
		return
	}
	defer f.Close()
	st, _ := f.Stat()
	w.Header().Set("Content-Type", "image/jpeg")
	w.Header().Set("Cache-Control", imageCacheControl)
	http.ServeContent(w, r, "", st.ModTime(), f)
}

// serveFromMemory is the mode without a disk (IMG_CACHE=none, for a serverless function): fetch, resize,
// send. Nothing is kept here; a CDN in front keeps the answer, which is why the headers say forever.
// ponytail: UpstreamPerHour counts per running instance, and a serverless platform may run several at once
// and restart them often, so the cap there is a brake on one instance, not a global limit.
func (p *ImageProxy) serveFromMemory(w http.ResponseWriter, r *http.Request, hash string, width int) {
	v, err, _ := p.group.Do(fmt.Sprintf("%s_%d", hash, width), func() (any, error) {
		ctx, cancel := context.WithTimeout(context.WithoutCancel(r.Context()), 25*time.Second)
		defer cancel()
		data, err := p.fetch(ctx, hash)
		if err != nil {
			return nil, err
		}
		return resize(data, width, hash)
	})
	if err != nil {
		p.fail(w, hash, err)
		return
	}
	out := v.([]byte)
	w.Header().Set("Content-Type", "image/jpeg")
	w.Header().Set("Content-Length", strconv.Itoa(len(out)))
	w.Header().Set("Cache-Control", imageCacheControl)
	w.Write(out)
}

// fail answers an image error. None of these answers is cached.
func (p *ImageProxy) fail(w http.ResponseWriter, hash string, err error) {
	switch {
	case errors.Is(err, errNotFound):
		writeErr(w, http.StatusNotFound, "no such image")
	case errors.Is(err, errBudget):
		w.Header().Set("Retry-After", strconv.Itoa(p.secondsToNextHour()))
		writeErr(w, http.StatusServiceUnavailable, "image budget for this hour is used up")
	case errors.Is(err, errBlocked):
		writeErr(w, http.StatusServiceUnavailable, "image source is unavailable")
	default:
		p.Log.Error("image", "hash", hash, "err", err)
		writeErr(w, http.StatusBadGateway, "could not load image")
	}
}

// resize scales a JPEG down to width, never up, and keeps the result under the response limit.
func resize(data []byte, width int, hash string) ([]byte, error) {
	src, _, err := image.Decode(bytes.NewReader(data))
	if err != nil {
		return nil, fmt.Errorf("decode %s: %w", hash, err)
	}
	b := src.Bounds()
	out := data
	var dst *image.RGBA
	if b.Dx() > width { // never upscale
		dst = image.NewRGBA(image.Rect(0, 0, width, max(1, (b.Dy()*width+b.Dx()/2)/b.Dx())))
		draw.CatmullRom.Scale(dst, dst.Bounds(), src, b, draw.Over, nil)
		var buf bytes.Buffer
		if err := jpeg.Encode(&buf, dst, &jpeg.Options{Quality: 82}); err != nil {
			return nil, err
		}
		out = buf.Bytes()
	}
	if len(out) > maxResponseBytes { // a huge original served as is: squeeze it once, then give up
		var buf bytes.Buffer
		var img image.Image = src
		if dst != nil {
			img = dst
		}
		if err := jpeg.Encode(&buf, img, &jpeg.Options{Quality: 65}); err != nil {
			return nil, err
		}
		if buf.Len() > maxResponseBytes {
			return nil, errTooLarge
		}
		out = buf.Bytes()
	}
	return out, nil
}

// build writes the resized copy at path, fetching the original only if it is not on disk.
func (p *ImageProxy) build(ctx context.Context, hash string, width int, path string) error {
	orig := filepath.Join(p.Dir, hash+".orig")
	data, err := os.ReadFile(orig)
	if err != nil {
		if data, err = p.fetch(ctx, hash); err != nil {
			return err
		}
		if err := writeAtomic(orig, data); err != nil {
			return err
		}
	}
	out, err := resize(data, width, hash)
	if err != nil {
		return err
	}
	return writeAtomic(path, out)
}

func (p *ImageProxy) fetch(ctx context.Context, hash string) ([]byte, error) {
	if p.blocked.Load() {
		return nil, errBlocked
	}
	select {
	case p.sem <- struct{}{}:
		defer func() { <-p.sem }()
	case <-ctx.Done():
		return nil, ctx.Err()
	}
	if p.blocked.Load() { // a request ahead of us in the queue may have been refused
		return nil, errBlocked
	}
	if !p.takeBudget() { // counted before the request, so a failing source cannot be hammered either
		return nil, errBudget
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, p.Upstream+hash+".jpg", nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("User-Agent", p.UserAgent)
	resp, err := p.HTTP.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	switch resp.StatusCode {
	case http.StatusOK:
		return io.ReadAll(io.LimitReader(resp.Body, maxImageBytes))
	case http.StatusNotFound:
		return nil, errNotFound
	case http.StatusUnauthorized, http.StatusForbidden:
		p.blocked.Store(true)
		p.Log.Error("image source refused us, stopping", "status", resp.StatusCode)
		return nil, errBlocked
	default:
		return nil, fmt.Errorf("upstream answered %d", resp.StatusCode)
	}
}

// takeBudget spends one upstream fetch from this hour's budget.
func (p *ImageProxy) takeBudget() bool {
	if p.UpstreamPerHour <= 0 {
		return true
	}
	p.mu.Lock()
	defer p.mu.Unlock()
	now := p.now()
	if p.hour.IsZero() || now.Sub(p.hour) >= time.Hour {
		p.hour, p.used = now, 0
	}
	if p.used >= p.UpstreamPerHour {
		return false
	}
	p.used++
	return true
}

func (p *ImageProxy) secondsToNextHour() int {
	p.mu.Lock()
	defer p.mu.Unlock()
	secs := int((p.hour.Add(time.Hour).Sub(p.now()) + time.Second - 1) / time.Second)
	return max(secs, 1)
}

func writeAtomic(path string, data []byte) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	tmp, err := os.CreateTemp(filepath.Dir(path), ".tmp-*")
	if err != nil {
		return err
	}
	_, werr := tmp.Write(data)
	cerr := tmp.Close()
	if err := errors.Join(werr, cerr); err != nil {
		os.Remove(tmp.Name())
		return err
	}
	return os.Rename(tmp.Name(), path)
}

// Package collector runs one sweep: the whole Malaysian catalogue, then a price for each product.
package collector

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"

	"eshop-radar/backend/internal/db"
	"eshop-radar/backend/internal/nintendo"
	"eshop-radar/backend/internal/pricing"
)

const (
	Provider = "nintendo-my"
	Region   = "MY"
	Currency = "MYR"
)

// Counts is what a run reports. PricesSeen counts entries the price API returned (duplicates
// ignored); Unpriced and InvalidPrices are the part of those that wrote nothing.
type Counts struct {
	ProductsSeen    int64 // distinct products upserted
	ProductsSkipped int64 // catalogue rows without an nsuid
	PricesSeen      int64
	Unpriced        int64 // no regular_price in the response
	InvalidPrices   int64 // rejected, never repaired
	PriceChanges    int64 // price_history rows added
}

type Sweep struct {
	Pool   *pgxpool.Pool
	Client *nintendo.Client
	Log    *slog.Logger
}

// Run does one sweep and records it in collection_runs. Work saved before a failure stays;
// the failure is recorded on the run and returned.
func (s *Sweep) Run(ctx context.Context) (int64, Counts, error) {
	q := db.New(s.Pool)
	runID, err := q.CreateRun(ctx, Provider)
	if err != nil {
		return 0, Counts{}, fmt.Errorf("create run: %w", err)
	}
	var c Counts
	sweepErr := s.sweep(ctx, q, runID, &c)

	status, msg := "succeeded", pgtype.Text{}
	if sweepErr != nil {
		status, msg = "failed", pgtype.Text{String: sweepErr.Error(), Valid: true}
	}
	// A cancelled run must still be recorded, so the final update gets its own context.
	fctx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 10*time.Second)
	defer cancel()
	finErr := q.FinishRun(fctx, db.FinishRunParams{
		ID: runID, Status: status, Error: msg,
		ProductsSeen: c.ProductsSeen, ProductsSkipped: c.ProductsSkipped, PricesSeen: c.PricesSeen,
		Unpriced: c.Unpriced, InvalidPrices: c.InvalidPrices, PriceChanges: c.PriceChanges,
	})
	return runID, c, errors.Join(sweepErr, finErr)
}

func (s *Sweep) sweep(ctx context.Context, q *db.Queries, runID int64, c *Counts) error {
	seen := map[string]bool{}
	var ids []string

	total, collected, err := s.Client.Catalogue(ctx, func(items []nintendo.Item) error {
		var fresh []nintendo.Item
		var skipped int64
		for _, it := range items {
			switch {
			case it.NSUID == nil || *it.NSUID == "":
				skipped++
			case !seen[*it.NSUID]:
				seen[*it.NSUID] = true
				fresh = append(fresh, it)
			}
		}
		err := pgx.BeginFunc(ctx, s.Pool, func(tx pgx.Tx) error {
			qt := q.WithTx(tx)
			for _, it := range fresh {
				if err := qt.UpsertProduct(ctx, db.UpsertProductParams{
					Nsuid: *it.NSUID, Title: it.Title, Publisher: it.Maker, Platform: it.Hard,
					Kind: it.Sform, SourceStatus: it.Ssitu, Raw: it.Raw,
				}); err != nil {
					return fmt.Errorf("upsert product %s: %w", *it.NSUID, err)
				}
			}
			return nil
		})
		if err != nil {
			return err
		}
		c.ProductsSkipped += skipped
		c.ProductsSeen += int64(len(fresh))
		for _, it := range fresh {
			ids = append(ids, *it.NSUID)
		}
		return nil
	})
	if err != nil {
		return fmt.Errorf("catalogue: %w", err)
	}
	if collected == 0 {
		return fmt.Errorf("catalogue returned no rows (total %d)", total)
	}
	if collected < total {
		return fmt.Errorf("catalogue incomplete: collected %d of %d rows", collected, total)
	}
	s.Log.Info("catalogue done", "rows", collected, "products", len(ids), "skipped", c.ProductsSkipped)

	for start := 0; start < len(ids); start += nintendo.PriceBatch {
		batch := ids[start:min(start+nintendo.PriceBatch, len(ids))]
		prices, err := s.Client.Prices(ctx, batch)
		if err != nil {
			return fmt.Errorf("prices %d-%d of %d: %w", start+1, start+len(batch), len(ids), err)
		}
		if len(prices) == 0 {
			return fmt.Errorf("prices %d-%d of %d: response had no entries", start+1, start+len(batch), len(ids))
		}
		bc, err := s.writeBatch(ctx, q, runID, batch, prices)
		if err != nil {
			return fmt.Errorf("prices %d-%d of %d: %w", start+1, start+len(batch), len(ids), err)
		}
		c.PricesSeen += bc.PricesSeen
		c.Unpriced += bc.Unpriced
		c.InvalidPrices += bc.InvalidPrices
		c.PriceChanges += bc.PriceChanges
	}
	return nil
}

// writeBatch stores one batch in a single transaction and returns the counts to add once it commits.
func (s *Sweep) writeBatch(ctx context.Context, q *db.Queries, runID int64, batch []string, prices []nintendo.Price) (Counts, error) {
	asked := make(map[string]bool, len(batch))
	for _, id := range batch {
		asked[id] = true
	}
	var bc Counts
	err := pgx.BeginFunc(ctx, s.Pool, func(tx pgx.Tx) error {
		qt := q.WithTx(tx)
		got := map[string]bool{}
		for _, p := range prices {
			if got[p.NSUID] {
				continue
			}
			got[p.NSUID] = true
			bc.PricesSeen++
			if !asked[p.NSUID] {
				s.Log.Warn("price for an id we did not ask for", "nsuid", p.NSUID)
				bc.InvalidPrices++
				continue
			}
			if p.Regular == nil {
				bc.Unpriced++
				continue
			}
			v, err := validate(p)
			if err != nil {
				s.Log.Warn("invalid price", "nsuid", p.NSUID, "err", err)
				bc.InvalidPrices++
				continue
			}
			// History first: it compares against the current row that UpsertPrice then overwrites.
			n, err := qt.InsertHistoryIfChanged(ctx, db.InsertHistoryIfChangedParams{
				Nsuid: p.NSUID, Region: Region, Currency: Currency, RegularMinor: v.regular,
				DiscountMinor: v.discount, DiscountStart: v.start, DiscountEnd: v.end, RunID: runID,
			})
			if err != nil {
				return fmt.Errorf("history %s: %w", p.NSUID, err)
			}
			if err := qt.UpsertPrice(ctx, db.UpsertPriceParams{
				Nsuid: p.NSUID, Region: Region, Currency: Currency, RegularMinor: v.regular,
				DiscountMinor: v.discount, DiscountStart: v.start, DiscountEnd: v.end, SalesStatus: p.SalesStatus,
			}); err != nil {
				return fmt.Errorf("price %s: %w", p.NSUID, err)
			}
			bc.PriceChanges += n
		}
		if missing := len(batch) - len(got); missing > 0 {
			s.Log.Warn("ids with no entry in the price response", "count", missing)
		}
		return nil
	})
	if err != nil {
		return Counts{}, err
	}
	return bc, nil
}

type validPrice struct {
	regular  int64
	discount pgtype.Int8
	start    pgtype.Timestamptz
	end      pgtype.Timestamptz
}

// validate turns a priced entry into minor units, or says why it must be rejected. It never repairs.
func validate(p nintendo.Price) (validPrice, error) {
	var v validPrice
	if p.Regular.Currency != Currency {
		return v, fmt.Errorf("regular price currency %q", p.Regular.Currency)
	}
	var err error
	if v.regular, err = pricing.ParseMinor(p.Regular.RawValue); err != nil {
		return v, fmt.Errorf("regular price: %w", err)
	}
	d := p.Discount
	if d == nil {
		return v, nil
	}
	if d.Currency != Currency {
		return v, fmt.Errorf("discount currency %q", d.Currency)
	}
	disc, err := pricing.ParseMinor(d.RawValue)
	if err != nil {
		return v, fmt.Errorf("discount price: %w", err)
	}
	if disc > v.regular {
		return v, fmt.Errorf("discount %d exceeds regular %d", disc, v.regular)
	}
	start, err := time.Parse(time.RFC3339, d.Start)
	if err != nil {
		return v, fmt.Errorf("discount start %q: %w", d.Start, err)
	}
	end, err := time.Parse(time.RFC3339, d.End)
	if err != nil {
		return v, fmt.Errorf("discount end %q: %w", d.End, err)
	}
	if !end.After(start) {
		return v, fmt.Errorf("discount ends %s before it starts %s", d.End, d.Start)
	}
	v.discount = pgtype.Int8{Int64: disc, Valid: true}
	v.start = pgtype.Timestamptz{Time: start, Valid: true}
	v.end = pgtype.Timestamptz{Time: end, Valid: true}
	return v, nil
}

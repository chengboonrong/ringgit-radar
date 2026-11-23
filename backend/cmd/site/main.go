// Command site writes the landing pages and Android pages into the Vercel output directory, after the
// Flutter web build is in <out>/app. See README, "Public release".
package main

import (
	"context"
	"flag"
	"fmt"
	"os"

	"eshop-radar/backend/site"
)

func main() {
	api := flag.String("api", "https://ringgit-radar-mu.vercel.app", "where to read the live numbers (/v1/status/prices)")
	apk := flag.String("apk", "", "the release APK to publish (required)")
	out := flag.String("out", "public", "the Vercel output directory")
	flag.Parse()
	if err := run(*api, *apk, *out); err != nil {
		fmt.Fprintln(os.Stderr, "site:", err)
		os.Exit(1)
	}
}

func run(api, apk, out string) error {
	if apk == "" {
		return fmt.Errorf("-apk is required")
	}
	st, err := site.FetchStatus(context.Background(), api)
	if err != nil {
		return err
	}
	if err := site.Build(site.Options{Out: out, APKPath: apk, Status: st}); err != nil {
		return err
	}
	fmt.Printf("site: wrote %s (%d products tracked)\n", out, st.ProductCount)
	return nil
}

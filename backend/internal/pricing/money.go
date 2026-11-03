// Package pricing holds money handling. Money is integer minor units (sen), never floats.
package pricing

import (
	"errors"
	"fmt"
	"math"
	"strings"
)

// ParseMinor converts a plain decimal string ("12.5", "72", "64.80") to minor units
// (1250, 7200, 6480). Only digits with an optional 1-2 digit fraction are accepted.
// ponytail: assumes 2 minor digits, which holds for MYR; other currencies need an exponent.
func ParseMinor(raw string) (int64, error) {
	whole, frac, hasFrac := strings.Cut(raw, ".")
	if !allDigits(whole) {
		return 0, fmt.Errorf("pricing: invalid amount %q", raw)
	}
	var fracMinor int64
	if hasFrac {
		if len(frac) < 1 || len(frac) > 2 || !allDigits(frac) {
			return 0, fmt.Errorf("pricing: invalid amount %q", raw)
		}
		fracMinor = int64(frac[0] - '0')
		if len(frac) == 2 {
			fracMinor = fracMinor*10 + int64(frac[1]-'0')
		} else {
			fracMinor *= 10
		}
	}
	var minor int64
	for _, d := range whole {
		digit := int64(d - '0')
		if minor > (math.MaxInt64-digit)/10 {
			return 0, errors.New("pricing: amount overflows")
		}
		minor = minor*10 + digit
	}
	if minor > (math.MaxInt64-fracMinor)/100 {
		return 0, errors.New("pricing: amount overflows")
	}
	return minor*100 + fracMinor, nil
}

func allDigits(s string) bool {
	if s == "" {
		return false
	}
	for i := 0; i < len(s); i++ {
		if s[i] < '0' || s[i] > '9' {
			return false
		}
	}
	return true
}

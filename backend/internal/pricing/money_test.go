package pricing

import "testing"

func TestParseMinor(t *testing.T) {
	ok := []struct {
		in   string
		want int64
	}{
		{"12.5", 1250},
		{"72", 7200},
		{"64.80", 6480},
		{"0", 0},
		{"0.00", 0},
		{"0.05", 5},
		{"0.5", 50},
		{"299", 29900},
		{"92233720368547758.07", 9223372036854775807},
	}
	for _, c := range ok {
		got, err := ParseMinor(c.in)
		if err != nil || got != c.want {
			t.Errorf("ParseMinor(%q) = %d, %v; want %d", c.in, got, err, c.want)
		}
	}

	bad := []string{
		"", " ", "12 ", " 12", "1 2", "-1", "-0", "+1", "12.345", "12.", ".5", ".",
		"1e3", "1E3", "1.5e1", "abc", "12a", "1,5", "١٢", "0x10", "1_000",
		"92233720368547758.08", "99999999999999999999",
	}
	for _, in := range bad {
		if got, err := ParseMinor(in); err == nil {
			t.Errorf("ParseMinor(%q) = %d, nil; want error", in, got)
		}
	}
}

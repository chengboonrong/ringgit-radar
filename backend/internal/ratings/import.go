package ratings

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"

	"eshop-radar/backend/internal/db"
)

// Result of an import. Conflicts counts products, ConflictNames the distinct dataset names behind them.
type Result struct {
	Games, Matched, Unmatched, Conflicts, ConflictNames int
}

// Import matches every game in products against ix and stores the matches. A game with no match, or
// whose name has conflicting ratings, gets no row (and loses any earlier one), so the table always
// reflects the latest run.
func Import(ctx context.Context, pool *pgxpool.Pool, ix *Index, source string) (Result, error) {
	q := db.New(pool)
	games, err := q.ListGameProducts(ctx)
	if err != nil {
		return Result{}, fmt.Errorf("list games: %w", err)
	}
	res := Result{Games: len(games)}
	var drop []string
	conflictNames := map[string]bool{}
	err = pgx.BeginFunc(ctx, pool, func(tx pgx.Tx) error {
		qt := q.WithTx(tx)
		for _, g := range games {
			m := ix.Lookup(g.Title)
			switch m.Status {
			case Matched:
				res.Matched++
				if err := qt.UpsertTitleRating(ctx, db.UpsertTitleRatingParams{
					Nsuid: g.Nsuid, Age: int32(m.Age), Descriptors: m.Descriptors, Source: source, MatchedName: m.MatchedName,
				}); err != nil {
					return fmt.Errorf("store rating for %s: %w", g.Nsuid, err)
				}
			case Conflict:
				res.Conflicts++
				conflictNames[m.Key] = true
				drop = append(drop, g.Nsuid)
			default:
				res.Unmatched++
				drop = append(drop, g.Nsuid)
			}
		}
		return qt.DeleteTitleRatings(ctx, drop)
	})
	res.ConflictNames = len(conflictNames)
	return res, err
}

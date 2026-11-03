-- name: ListGameProducts :many
-- Games only: add-ons and bundles are not rated by title.
SELECT nsuid, title FROM products WHERE raw->>'sctg' = 'dl_soft' ORDER BY nsuid;

-- name: UpsertTitleRating :exec
INSERT INTO title_ratings (nsuid, age, descriptors, source, matched_name)
VALUES ($1, $2, $3, $4, $5)
ON CONFLICT (nsuid) DO UPDATE SET
    age = EXCLUDED.age,
    descriptors = EXCLUDED.descriptors,
    source = EXCLUDED.source,
    matched_name = EXCLUDED.matched_name,
    imported_at = now();

-- name: DeleteTitleRatings :exec
DELETE FROM title_ratings WHERE nsuid = ANY(sqlc.arg(nsuids)::text[]);

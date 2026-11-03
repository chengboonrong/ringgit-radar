-- Read queries for the API. All of them read the catalog view.

-- name: ListGames :many
-- types, platforms, genres, ages (PEGI), ids, q (an ILIKE pattern), max_price (sen) and release are optional
-- filters. A game with no rating is listed unless ages is set.
SELECT sqlc.embed(c), (count(*) OVER ())::bigint AS total
FROM catalog c
WHERE c.category = ANY(sqlc.arg(types)::text[])
  AND (sqlc.narg(platforms)::text[] IS NULL OR c.platform = ANY(sqlc.narg(platforms)::text[]))
  AND (sqlc.narg(genres)::text[] IS NULL OR c.genres && sqlc.narg(genres)::text[])
  AND (sqlc.narg(q)::text IS NULL OR c.title ILIKE sqlc.narg(q)::text ESCAPE '\')
  AND (sqlc.narg(ages)::int[] IS NULL OR c.age = ANY(sqlc.narg(ages)::int[]))
  AND (NOT sqlc.arg(on_sale)::bool OR c.on_sale)
  AND (sqlc.narg(max_price)::bigint IS NULL OR c.price_minor <= sqlc.narg(max_price)::bigint)
  AND (sqlc.narg(ids)::text[] IS NULL OR c.nsuid = ANY(sqlc.narg(ids)::text[]))
  AND (sqlc.narg(ids)::text[] IS NOT NULL OR c.source_status NOT IN ('sales_termination', 'not_found'))
  AND (sqlc.arg(include_flagged)::bool OR NOT c.flagged)
  AND (sqlc.narg(release)::text IS NULL
       OR (sqlc.narg(release)::text = 'recent'
           AND c.release_date BETWEEN (now() AT TIME ZONE 'Asia/Kuala_Lumpur')::date - 30
                                  AND (now() AT TIME ZONE 'Asia/Kuala_Lumpur')::date)
       OR (sqlc.narg(release)::text = 'upcoming'
           AND (c.release_date > (now() AT TIME ZONE 'Asia/Kuala_Lumpur')::date
                OR (c.release_date IS NULL AND c.source_status IN ('unreleased', 'preorder')))))
ORDER BY
  CASE WHEN sqlc.arg(sort)::text = 'savings' THEN c.saved_minor END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort)::text = 'discount' THEN c.percent_off END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort)::text IN ('savings', 'discount') THEN c.percent_off END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort)::text = 'discount' THEN c.saved_minor END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort)::text = 'price' THEN c.price_minor END ASC NULLS LAST,
  CASE WHEN sqlc.arg(sort)::text = 'newest' AND c.release_date > (now() AT TIME ZONE 'Asia/Kuala_Lumpur')::date THEN 1 ELSE 0 END ASC,
  CASE WHEN sqlc.arg(sort)::text = 'newest' THEN c.release_date END DESC NULLS LAST,
  CASE WHEN sqlc.arg(sort)::text = 'soonest' THEN c.release_date END ASC NULLS LAST,
  CASE WHEN sqlc.arg(sort)::text = 'ending' AND c.on_sale THEN c.discount_end END ASC NULLS LAST,
  lower(c.title) ASC,
  c.nsuid ASC
LIMIT sqlc.arg(lim)::int OFFSET sqlc.arg(off)::int;

-- name: GetGame :one
SELECT * FROM catalog WHERE nsuid = $1;

-- name: ListPriceHistory :many
SELECT observed_at, regular_minor, discount_minor, discount_start, discount_end
FROM price_history
WHERE nsuid = $1 AND region = 'MY'
ORDER BY observed_at ASC, id ASC;

-- name: TopSavings :many
-- Biggest ringgit saved right now, at most 3 per publisher. Used by Highlights and Ranking.
WITH ranked AS (
  SELECT c.nsuid, c.saved_minor,
         row_number() OVER (PARTITION BY c.publisher ORDER BY c.saved_minor DESC, c.nsuid) AS pub_rank
  FROM catalog c
  WHERE c.category = 'game' AND NOT c.flagged AND c.on_sale
    AND c.source_status NOT IN ('sales_termination', 'not_found')
    AND (sqlc.narg(platform)::text IS NULL OR c.platform = sqlc.narg(platform)::text)
)
SELECT sqlc.embed(c)
FROM ranked r JOIN catalog c ON c.nsuid = r.nsuid
WHERE r.pub_rank <= 3
ORDER BY r.saved_minor DESC, c.nsuid
LIMIT sqlc.arg(lim)::int;

-- name: EndingSoon :many
WITH ranked AS (
  SELECT c.nsuid, c.discount_end,
         row_number() OVER (PARTITION BY c.publisher ORDER BY c.discount_end, c.saved_minor DESC, c.nsuid) AS pub_rank
  FROM catalog c
  WHERE c.category = 'game' AND NOT c.flagged AND c.on_sale
    AND c.source_status NOT IN ('sales_termination', 'not_found')
    AND c.discount_end <= now() + interval '3 days'
)
SELECT sqlc.embed(c)
FROM ranked r JOIN catalog c ON c.nsuid = r.nsuid
WHERE r.pub_rank <= 3
ORDER BY r.discount_end, c.nsuid
LIMIT sqlc.arg(lim)::int;

-- name: NewSales :many
WITH ranked AS (
  SELECT c.nsuid, c.saved_minor,
         row_number() OVER (PARTITION BY c.publisher ORDER BY c.saved_minor DESC, c.nsuid) AS pub_rank
  FROM catalog c
  WHERE c.category = 'game' AND NOT c.flagged AND c.on_sale
    AND c.source_status NOT IN ('sales_termination', 'not_found')
    AND c.discount_start >= now() - interval '7 days'
)
SELECT sqlc.embed(c)
FROM ranked r JOIN catalog c ON c.nsuid = r.nsuid
WHERE r.pub_rank <= 3
ORDER BY r.saved_minor DESC, c.nsuid
LIMIT sqlc.arg(lim)::int;

-- name: RecentReleases :many
WITH ranked AS (
  SELECT c.nsuid, c.release_date,
         row_number() OVER (PARTITION BY c.publisher ORDER BY c.release_date DESC, c.nsuid) AS pub_rank
  FROM catalog c
  WHERE c.category = 'game' AND NOT c.flagged
    AND c.source_status NOT IN ('sales_termination', 'not_found')
    AND c.release_date BETWEEN (now() AT TIME ZONE 'Asia/Kuala_Lumpur')::date - 30
                           AND (now() AT TIME ZONE 'Asia/Kuala_Lumpur')::date
)
SELECT sqlc.embed(c)
FROM ranked r JOIN catalog c ON c.nsuid = r.nsuid
WHERE r.pub_rank <= 3
ORDER BY r.release_date DESC, c.nsuid
LIMIT sqlc.arg(lim)::int;

-- name: ListGenres :many
-- cover is one game's art for the genre tile: Switch 2 first, then games with at least 3 screenshots, then
-- a fixed order from md5(genre || nsuid). It is the same game on every call, but different genres pick
-- different games. Flagged and art-less games are never the cover. An empty cover means no art at all.
SELECT g.name::text AS name,
       count(*)::bigint AS count,
       coalesce((array_agg(g.image ORDER BY (g.platform = 'switch2') DESC, (g.shots >= 3) DESC, md5(g.name || g.nsuid))
                 FILTER (WHERE g.image <> ''))[1], '')::text AS cover
FROM (
  SELECT unnest(c.genres) AS name, c.image, c.platform, c.nsuid, cardinality(c.screenshots) AS shots
  FROM catalog c
  WHERE c.category = 'game' AND NOT c.flagged AND c.source_status NOT IN ('sales_termination', 'not_found')
) g
GROUP BY g.name
ORDER BY count(*) DESC, g.name;

-- name: StatusPrices :one
SELECT
  (SELECT max(finished_at) FROM collection_runs WHERE status = 'succeeded')::timestamptz AS last_run_at,
  (SELECT count(*) FROM products)::bigint AS product_count,
  (SELECT min(observed_at) FROM price_history)::timestamptz AS history_since;

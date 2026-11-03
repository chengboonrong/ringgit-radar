-- name: CreateRun :one
INSERT INTO collection_runs (provider, status) VALUES ($1, 'running') RETURNING id;

-- name: FinishRun :exec
UPDATE collection_runs SET
    status = sqlc.arg(status)::text,
    finished_at = now(),
    products_seen = sqlc.arg(products_seen),
    products_skipped = sqlc.arg(products_skipped),
    prices_seen = sqlc.arg(prices_seen),
    unpriced = sqlc.arg(unpriced),
    invalid_prices = sqlc.arg(invalid_prices),
    price_changes = sqlc.arg(price_changes),
    error = sqlc.narg(error)
WHERE id = sqlc.arg(id);

-- name: UpsertProduct :exec
INSERT INTO products (nsuid, title, publisher, platform, kind, source_status, raw)
VALUES ($1, $2, $3, $4, $5, $6, $7)
ON CONFLICT (nsuid) DO UPDATE SET
    title = EXCLUDED.title,
    publisher = EXCLUDED.publisher,
    platform = EXCLUDED.platform,
    kind = EXCLUDED.kind,
    source_status = EXCLUDED.source_status,
    raw = EXCLUDED.raw,
    last_seen_at = now();

-- Adds a history row only when no current row holds exactly these values
-- (IS NOT DISTINCT FROM, so NULL discounts compare equal). Call before UpsertPrice.
-- name: InsertHistoryIfChanged :execrows
INSERT INTO price_history (nsuid, region, currency, regular_minor, discount_minor, discount_start, discount_end, run_id)
SELECT sqlc.arg(nsuid)::text, sqlc.arg(region)::text, sqlc.arg(currency)::text, sqlc.arg(regular_minor)::bigint,
       sqlc.narg(discount_minor)::bigint, sqlc.narg(discount_start)::timestamptz, sqlc.narg(discount_end)::timestamptz,
       sqlc.arg(run_id)::bigint
WHERE NOT EXISTS (
    SELECT 1 FROM prices p
    WHERE p.nsuid = sqlc.arg(nsuid)::text AND p.region = sqlc.arg(region)::text
      AND (p.regular_minor, p.discount_minor, p.discount_start, p.discount_end)
          IS NOT DISTINCT FROM (sqlc.arg(regular_minor)::bigint, sqlc.narg(discount_minor)::bigint,
                                sqlc.narg(discount_start)::timestamptz, sqlc.narg(discount_end)::timestamptz)
);

-- name: UpsertPrice :exec
INSERT INTO prices (nsuid, region, currency, regular_minor, discount_minor, discount_start, discount_end, sales_status)
VALUES (sqlc.arg(nsuid), sqlc.arg(region), sqlc.arg(currency), sqlc.arg(regular_minor),
        sqlc.narg(discount_minor), sqlc.narg(discount_start), sqlc.narg(discount_end), sqlc.arg(sales_status))
ON CONFLICT (nsuid, region) DO UPDATE SET
    currency = EXCLUDED.currency,
    regular_minor = EXCLUDED.regular_minor,
    discount_minor = EXCLUDED.discount_minor,
    discount_start = EXCLUDED.discount_start,
    discount_end = EXCLUDED.discount_end,
    sales_status = EXCLUDED.sales_status,
    checked_at = now();

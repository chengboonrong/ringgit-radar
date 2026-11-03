-- eShop Radar schema. Money is integer minor units (sen). Products are never deleted.

CREATE TABLE products (
    nsuid         text PRIMARY KEY,
    title         text NOT NULL DEFAULT '',
    publisher     text NOT NULL DEFAULT '',  -- source: maker
    platform      text NOT NULL DEFAULT '',  -- source: hard
    kind          text NOT NULL DEFAULT '',  -- source: sform
    source_status text NOT NULL DEFAULT '',  -- source: ssitu
    raw           jsonb NOT NULL,            -- the whole source item
    first_seen_at timestamptz NOT NULL DEFAULT now(),
    last_seen_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE collection_runs (
    id                bigserial PRIMARY KEY,
    provider          text NOT NULL,
    status            text NOT NULL CHECK (status IN ('running', 'succeeded', 'failed')),
    started_at        timestamptz NOT NULL DEFAULT now(),
    finished_at       timestamptz,
    products_seen     bigint NOT NULL DEFAULT 0,
    products_skipped  bigint NOT NULL DEFAULT 0,
    prices_seen       bigint NOT NULL DEFAULT 0,
    unpriced          bigint NOT NULL DEFAULT 0,
    invalid_prices    bigint NOT NULL DEFAULT 0,
    price_changes     bigint NOT NULL DEFAULT 0,
    error             text
);

-- Current state: one row per product and region.
CREATE TABLE prices (
    nsuid          text NOT NULL REFERENCES products (nsuid),
    region         text NOT NULL,
    currency       text NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
    regular_minor  bigint NOT NULL CHECK (regular_minor >= 0),
    discount_minor bigint CHECK (discount_minor >= 0),
    discount_start timestamptz,
    discount_end   timestamptz,
    sales_status   text NOT NULL DEFAULT '',
    checked_at     timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (nsuid, region)
);

-- Immutable: a row is added only when the price, discount or discount window changes.
CREATE TABLE price_history (
    id             bigserial PRIMARY KEY,
    nsuid          text NOT NULL REFERENCES products (nsuid),
    region         text NOT NULL,
    currency       text NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
    regular_minor  bigint NOT NULL CHECK (regular_minor >= 0),
    discount_minor bigint CHECK (discount_minor >= 0),
    discount_start timestamptz,
    discount_end   timestamptz,
    observed_at    timestamptz NOT NULL DEFAULT now(),
    run_id         bigint NOT NULL REFERENCES collection_runs (id)
);

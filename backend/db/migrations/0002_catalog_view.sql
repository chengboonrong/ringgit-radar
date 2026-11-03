-- Read model for the API: one row per product with its current MY price and the source fields
-- the app needs, pulled out of products.raw. Money stays integer sen.
-- A discount counts as live only while now() is inside its window, so a sale that ended since the
-- last sweep is not shown as on sale.
CREATE VIEW catalog AS
SELECT
    x.nsuid,
    x.title,
    x.publisher,
    x.category,
    x.platform,
    x.release_date::date AS release_date,
    x.sdate::text AS sdate,
    coalesce(x.image, '')::text AS image,
    x.screenshots,
    x.dcolors,
    x.genres,
    x.description::text AS description,
    x.tagline::text AS tagline,
    x.players::text AS players,
    x.addons,
    x.source_status,
    x.currency,
    x.regular_minor,
    x.discount_minor,
    x.discount_start,
    x.discount_end,
    x.sales_status,
    x.checked_at,
    x.on_sale::boolean AS on_sale,
    (CASE WHEN x.on_sale THEN x.discount_minor ELSE x.regular_minor END)::bigint AS price_minor,
    CASE WHEN x.on_sale THEN x.regular_minor - x.discount_minor ELSE 0::bigint END AS saved_minor,
    -- floor, so a percentage never overstates the saving
    CASE WHEN x.on_sale THEN ((x.regular_minor - x.discount_minor) * 100 / x.regular_minor)::int ELSE 0 END AS percent_off,
    -- ponytail: a keyword match on the title, so "Comic Strip" or "Dirty Rally" are flagged too and
    -- anything with a tame title slips through; a reviewed per-nsuid list is the next step
    (x.title ~* '\m(hentai|panty|panties|waifus?|catgirls?|dirty|erotic|sexy|nsfw|strip)\M')::boolean AS flagged
FROM (
    SELECT
        p.nsuid,
        p.title,
        p.publisher,
        CASE p.raw->>'sctg'
            WHEN 'dl_soft' THEN 'game'
            WHEN 'bundle' THEN 'bundle'
            WHEN 'aoc' THEN 'addon'
            ELSE 'other'
        END AS category,
        CASE p.platform WHEN '05_BEE' THEN 'switch2' WHEN '1_HAC' THEN 'switch' ELSE 'other' END AS platform,
        CASE WHEN p.raw->>'dsdate' ~ '^\d{4}-\d{2}-\d{2}'
             THEN substr(p.raw->>'dsdate', 1, 10)::date END AS release_date,
        coalesce(p.raw->>'sdate', '') AS sdate,
        p.raw->>'iurl' AS image,
        CASE WHEN jsonb_typeof(p.raw->'sslurl') = 'array'
             THEN ARRAY(SELECT jsonb_array_elements_text(p.raw->'sslurl')) ELSE ARRAY[]::text[] END AS screenshots,
        CASE WHEN jsonb_typeof(p.raw->'dcolors') = 'array'
             THEN ARRAY(SELECT jsonb_array_elements_text(p.raw->'dcolors')) ELSE ARRAY[]::text[] END AS dcolors,
        CASE WHEN jsonb_typeof(p.raw->'genre') = 'array'
             THEN ARRAY(SELECT jsonb_array_elements_text(p.raw->'genre')) ELSE ARRAY[]::text[] END AS genres,
        coalesce(p.raw->>'text', '') AS description,
        coalesce(p.raw->'hcopy'->>0, '') AS tagline,
        coalesce(p.raw->'player'->>0, '') AS players,
        CASE WHEN jsonb_typeof(p.raw->'cnsuid') = 'array'
             THEN ARRAY(SELECT jsonb_array_elements_text(p.raw->'cnsuid')) ELSE ARRAY[]::text[] END AS addons,
        p.source_status,
        pr.currency,
        pr.regular_minor,
        pr.discount_minor,
        pr.discount_start,
        pr.discount_end,
        pr.sales_status,
        pr.checked_at,
        coalesce(pr.discount_minor IS NOT NULL
            AND pr.regular_minor > 0
            AND pr.discount_minor < pr.regular_minor
            AND now() >= pr.discount_start
            AND now() < pr.discount_end, false) AS on_sale
    FROM products p
    LEFT JOIN prices pr ON pr.nsuid = p.nsuid AND pr.region = 'MY'
) x;

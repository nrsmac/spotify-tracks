with source as (
    select * from {{ source('spotify_raw', 'raw__available_markets') }}
),

filtered as (
    select
        rowid as available_markets_rowid, -- renamed from `rowid`
        available_markets
    from source
    where available_markets != 'unavailable' -- filters out special "unavailable" value (rowid=1)
)

-- unnests comma-separated available_markets string into individual rows
-- unique combination of (available_markets_rowid, market_code) (schema.yml)
select
    available_markets_rowid, -- not_null (schema.yml)
    unnest(string_split(available_markets, ',')) as market_code -- not_null (schema.yml)
from filtered

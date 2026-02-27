with source as (
    select * from {{ source('spotify_raw', 'raw__artists') }}
)

select
    rowid as artist_rowid, -- renamed from `rowid`
    id, -- unique + not_null (schema.yml)
    epoch_ms(fetched_at) as fetched_at,
    name,
    followers_total, -- >= 0 (schema.yml)
    popularity -- accepted_range 0–100 (schema.yml)
from source

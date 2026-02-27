with source as (
    select * from {{ source('spotify_raw', 'raw__tracks') }}
)

select
    rowid as track_rowid, -- renamed from `rowid`
    id, -- unique + not_null (schema.yml)
    epoch_ms(fetched_at) as fetched_at,
    name,
    preview_url,
    album_rowid,
    track_number,
    external_id_isrc,
    popularity, -- accepted_range 0–100 (schema.yml)
    available_markets_rowid,
    disc_number,
    duration_ms, -- > 0 after filter (schema.yml)
    explicit::boolean as explicit,
    (name is null or name = '') as is_name_empty, -- flags 65,032 rows with empty name
    (external_id_isrc is null or external_id_isrc = '') as is_missing_isrc -- flags 104,792 rows
from source
where duration_ms != 0 -- filters out 65,954 rows with zero duration

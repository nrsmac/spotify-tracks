with source as (
    select * from {{ source('spotify_raw', 'raw__playlists') }}
)

select
    rowid as playlist_rowid, -- renamed from `rowid`
    id, -- unique + not_null (schema.yml)
    snapshot_id,
    epoch_ms(fetched_at) as fetched_at,
    name,
    description,
    collaborative::boolean as collaborative,
    public::boolean as public,
    primary_color,
    owner_id,
    owner_display_name,
    followers_total, -- >= 0 (schema.yml)
    tracks_total,
    (name is null or name = '') as is_name_empty, -- flags 258 rows with empty name
    (owner_id is null or owner_id = '') as is_missing_owner -- flags 2,817 rows
from source

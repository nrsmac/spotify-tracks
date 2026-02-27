with source as (
    select * from {{ source('spotify_raw', 'raw__playlist_tracks') }}
)

select
    playlist_rowid, -- relationships to stg__playlists (schema.yml)
    position,
    is_episode::boolean as is_episode,
    track_rowid, -- relationships to stg__tracks (schema.yml)
    id_if_not_in_tracks_table,
    case when added_at > 0 then to_timestamp(added_at) else null end as added_at,
    added_by_id,
    primary_color,
    video_thumbnail_url,
    is_local::boolean as is_local,
    name_if_is_local,
    uri_if_is_local,
    album_name_if_is_local,
    artists_name_if_is_local,
    duration_ms_if_is_local
from source

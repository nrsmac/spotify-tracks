with source as (
    select * from {{ source('spotify_raw', 'playlist_tracks') }}
)
select * from source

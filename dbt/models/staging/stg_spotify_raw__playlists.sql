with source as (
    select * from {{ source('spotify_raw', 'playlists') }}
)
select * from source

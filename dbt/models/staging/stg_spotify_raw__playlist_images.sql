with source as (
    select * from {{ source('spotify_raw', 'playlist_images') }}
)
select * from source

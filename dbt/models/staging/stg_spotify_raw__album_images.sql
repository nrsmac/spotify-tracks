with source as (
    select * from {{ source('spotify_raw', 'album_images') }}
)
select * from source

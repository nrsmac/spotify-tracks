with source as (
    select * from {{ source('spotify_raw', 'artist_images') }}
)
select * from source

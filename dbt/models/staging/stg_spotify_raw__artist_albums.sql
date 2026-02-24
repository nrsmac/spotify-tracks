with source as (
    select * from {{ source('spotify_raw', 'artist_albums') }}
)
select * from source

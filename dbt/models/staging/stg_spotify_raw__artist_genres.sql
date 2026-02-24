with source as (
    select * from {{ source('spotify_raw', 'artist_genres') }}
)
select * from source

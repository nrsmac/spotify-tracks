with source as (
    select * from {{ source('spotify_raw', 'artist_redirects') }}
)
select * from source

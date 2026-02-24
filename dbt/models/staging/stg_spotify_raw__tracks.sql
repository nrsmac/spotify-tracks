with source as (
    select * from {{ source('spotify_raw', 'tracks') }}
)
select * from source

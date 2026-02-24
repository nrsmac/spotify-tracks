with source as (
    select * from {{ source('spotify_raw', 'available_markets') }}
)
select * from source

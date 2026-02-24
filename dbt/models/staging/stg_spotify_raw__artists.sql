with source as (
    select * from {{ source('spotify_raw', 'artists') }}
)
select * from source

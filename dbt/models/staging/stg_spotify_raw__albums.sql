with source as (
    select * from {{ source('spotify_raw', 'albums') }}
)
select * from source

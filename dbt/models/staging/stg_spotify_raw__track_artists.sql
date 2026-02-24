with source as (
    select * from {{ source('spotify_raw', 'track_artists') }}
)
select * from source

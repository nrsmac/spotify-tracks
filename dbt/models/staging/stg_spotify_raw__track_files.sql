with source as (
    select * from {{ source('spotify_raw', 'track_files') }}
)
select * from source

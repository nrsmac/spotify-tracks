with source as (
    select * from {{ source('spotify_raw', 'track_audio_features') }}
)
select * from source

with source as (
    select * from {{ source('spotify_raw', 'raw__track_audio_features') }}
)

select
    rowid::bigint as rowid,
    track_id, -- unique (schema.yml)
    epoch_ms(fetched_at::bigint) as fetched_at,
    -- null_response column dropped after filtering
    duration_ms::integer as duration_ms,
    time_signature::integer as time_signature, -- accepted_range 0–7 (schema.yml)
    tempo::float as tempo,
    key::integer as key, -- accepted_range -1–11 (schema.yml)
    mode::integer as mode, -- accepted_values [0, 1] (schema.yml)
    danceability::float as danceability, -- accepted_range 0–1 (schema.yml)
    energy::float as energy, -- accepted_range 0–1 (schema.yml)
    loudness::float as loudness,
    speechiness::float as speechiness, -- accepted_range 0–1 (schema.yml)
    acousticness::float as acousticness, -- accepted_range 0–1 (schema.yml)
    instrumentalness::float as instrumentalness, -- accepted_range 0–1 (schema.yml)
    liveness::float as liveness, -- accepted_range 0–1 (schema.yml)
    valence::float as valence -- accepted_range 0–1 (schema.yml)
from source
where not null_response::boolean -- filters out 773,795 rows where features are all NULL

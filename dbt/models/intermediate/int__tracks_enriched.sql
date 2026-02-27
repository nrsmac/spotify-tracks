with tracks as (
    select * from {{ ref('stg__tracks') }}
),

albums as (
    select * from {{ ref('stg__albums') }}
),

audio_features as (
    select * from {{ ref('stg__track_audio_features') }}
)

select
    t.track_rowid,
    t.id as track_id,
    t.name as track_name,
    t.popularity as track_popularity,
    t.duration_ms,
    t.explicit,
    t.track_number,
    t.disc_number,
    t.external_id_isrc,
    t.available_markets_rowid as track_available_markets_rowid,

    a.album_rowid,
    a.id as album_id,
    a.name as album_name,
    a.album_type,
    a.label,
    a.release_date,
    a.release_date_parsed,
    a.release_date_precision,
    a.is_bogus_date,
    extract(year from a.release_date_parsed) as release_year,
    (extract(year from a.release_date_parsed) // 10) * 10 as release_decade,
    a.available_markets_rowid as album_available_markets_rowid,

    af.danceability,
    af.energy,
    af.loudness,
    af.speechiness,
    af.acousticness,
    af.instrumentalness,
    af.liveness,
    af.valence,
    af.tempo,
    af.key,
    af.mode,
    af.time_signature,
    af.track_id is not null as has_audio_features

from tracks t
left join albums a on t.album_rowid = a.album_rowid
left join audio_features af on t.id = af.track_id

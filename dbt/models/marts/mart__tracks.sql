-- Performance: artist name aggregation is pre-computed in int__track_artist_names,
-- so this model is a simple 256M × 256M equi-join on track_rowid with no aggregation.

with tracks_enriched as (
    select * from {{ ref('int__tracks_enriched') }}
),

artist_names as (
    select * from {{ ref('int__track_artist_names') }}
)

select
    t.track_rowid,
    t.track_id,
    t.track_name,
    t.track_popularity,
    t.duration_ms,
    t.explicit,
    t.track_number,
    t.disc_number,
    t.external_id_isrc,

    an.artist_names,
    an.artist_count,

    t.album_rowid,
    t.album_id,
    t.album_name,
    t.album_type,
    t.label,
    t.release_date_parsed,
    t.release_year,
    t.release_decade,
    t.is_bogus_date,

    t.danceability,
    t.energy,
    t.loudness,
    t.speechiness,
    t.acousticness,
    t.instrumentalness,
    t.liveness,
    t.valence,
    t.tempo,
    t.key,
    t.mode,
    t.time_signature,
    t.has_audio_features

from tracks_enriched t
left join artist_names an on t.track_rowid = an.track_rowid

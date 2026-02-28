with tracks_enriched as (
    select * from {{ ref('int__tracks_enriched') }}
)

select
    label,
    release_year,
    count(*) as track_count,
    count(distinct album_rowid) as album_count,
    avg(track_popularity) as avg_track_popularity,
    max(track_popularity) as max_track_popularity,
    avg(danceability) filter (where has_audio_features) as avg_danceability,
    avg(energy) filter (where has_audio_features) as avg_energy,
    avg(valence) filter (where has_audio_features) as avg_valence,
    avg(tempo) filter (where has_audio_features) as avg_tempo,
    avg(loudness) filter (where has_audio_features) as avg_loudness,
    count(*) filter (where explicit) as explicit_track_count,
    count(*) filter (where has_audio_features) as tracks_with_audio_features

from tracks_enriched
where label is not null
    and label != ''
    and release_year is not null
group by label, release_year

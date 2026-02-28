with albums as (
    select * from {{ ref('stg__albums') }}
),

tracks_enriched as (
    select * from {{ ref('int__tracks_enriched') }}
),

artist_albums as (
    select * from {{ ref('stg__artist_albums') }}
),

artists as (
    select * from {{ ref('stg__artists') }}
),

track_stats as (
    select
        album_rowid,
        count(*) as track_count,
        avg(track_popularity) as avg_track_popularity,
        max(track_popularity) as max_track_popularity,
        sum(duration_ms) as total_duration_ms,
        avg(danceability) as avg_danceability,
        avg(energy) as avg_energy,
        avg(valence) as avg_valence,
        avg(tempo) as avg_tempo,
        avg(loudness) as avg_loudness,
        count(*) filter (where explicit) as explicit_track_count,
        count(*) filter (where has_audio_features) as tracks_with_audio_features
    from tracks_enriched
    group by album_rowid
),

album_artists as (
    select
        aa.album_rowid,
        string_agg(a.name, ', ' order by a.name) as artist_names,
        count(*) as artist_count
    from artist_albums aa
    inner join artists a on aa.artist_rowid = a.artist_rowid
    group by aa.album_rowid
)

select
    al.album_rowid,
    al.id as album_id,
    al.name as album_name,
    al.album_type,
    al.label,
    al.popularity as album_popularity,
    al.release_date_parsed,
    extract(year from al.release_date_parsed) as release_year,
    (extract(year from al.release_date_parsed) // 10) * 10 as release_decade,
    al.release_date_precision,
    al.is_bogus_date,
    al.total_tracks,

    aa.artist_names,
    aa.artist_count,

    ts.track_count,
    ts.avg_track_popularity,
    ts.max_track_popularity,
    ts.total_duration_ms,
    ts.avg_danceability,
    ts.avg_energy,
    ts.avg_valence,
    ts.avg_tempo,
    ts.avg_loudness,
    ts.explicit_track_count,
    ts.tracks_with_audio_features

from albums al
left join album_artists aa on al.album_rowid = aa.album_rowid
left join track_stats ts on al.album_rowid = ts.album_rowid

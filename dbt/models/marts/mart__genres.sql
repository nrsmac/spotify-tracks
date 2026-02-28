with artist_genres as (
    select * from {{ ref('stg__artist_genres') }}
),

artists as (
    select * from {{ ref('stg__artists') }}
),

track_artists as (
    select * from {{ ref('stg__track_artists') }}
),

tracks_enriched as (
    select * from {{ ref('int__tracks_enriched') }}
),

genre_artists as (
    select
        ag.genre,
        ag.artist_rowid,
        a.popularity as artist_popularity,
        a.followers_total
    from artist_genres ag
    inner join artists a on ag.artist_rowid = a.artist_rowid
),

genre_tracks as (
    select distinct
        ag.genre,
        te.track_rowid,
        te.track_popularity,
        te.danceability,
        te.energy,
        te.loudness,
        te.speechiness,
        te.acousticness,
        te.instrumentalness,
        te.liveness,
        te.valence,
        te.tempo,
        te.key,
        te.mode,
        te.explicit,
        te.release_year,
        te.has_audio_features
    from artist_genres ag
    inner join track_artists ta on ag.artist_rowid = ta.artist_rowid
    inner join tracks_enriched te on ta.track_rowid = te.track_rowid
),

genre_artist_stats as (
    select
        genre,
        count(*) as artist_count,
        avg(artist_popularity) as avg_artist_popularity,
        sum(followers_total) as total_followers
    from genre_artists
    group by genre
),

genre_track_stats as (
    select
        genre,
        count(*) as track_count,
        avg(track_popularity) as avg_track_popularity,
        avg(danceability) filter (where has_audio_features) as avg_danceability,
        avg(energy) filter (where has_audio_features) as avg_energy,
        avg(loudness) filter (where has_audio_features) as avg_loudness,
        avg(speechiness) filter (where has_audio_features) as avg_speechiness,
        avg(acousticness) filter (where has_audio_features) as avg_acousticness,
        avg(instrumentalness) filter (where has_audio_features) as avg_instrumentalness,
        avg(liveness) filter (where has_audio_features) as avg_liveness,
        avg(valence) filter (where has_audio_features) as avg_valence,
        avg(tempo) filter (where has_audio_features) as avg_tempo,
        mode(key) filter (where has_audio_features) as most_common_key,
        mode(mode) filter (where has_audio_features) as most_common_mode,
        count(*) filter (where explicit) as explicit_track_count,
        count(*) filter (where has_audio_features) as tracks_with_audio_features,
        min(release_year) as earliest_release_year,
        max(release_year) as latest_release_year
    from genre_tracks
    group by genre
)

select
    gas.genre,
    gas.artist_count,
    gas.avg_artist_popularity,
    gas.total_followers,

    gts.track_count,
    gts.avg_track_popularity,
    gts.avg_danceability,
    gts.avg_energy,
    gts.avg_loudness,
    gts.avg_speechiness,
    gts.avg_acousticness,
    gts.avg_instrumentalness,
    gts.avg_liveness,
    gts.avg_valence,
    gts.avg_tempo,
    gts.most_common_key,
    gts.most_common_mode,
    gts.explicit_track_count,
    gts.tracks_with_audio_features,
    gts.earliest_release_year,
    gts.latest_release_year

from genre_artist_stats gas
left join genre_track_stats gts on gas.genre = gts.genre

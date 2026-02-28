with artists as (
    select * from {{ ref('stg__artists') }}
),

artist_genres as (
    select * from {{ ref('stg__artist_genres') }}
),

track_artists as (
    select * from {{ ref('stg__track_artists') }}
),

tracks_enriched as (
    select * from {{ ref('int__tracks_enriched') }}
),

artist_albums as (
    select * from {{ ref('stg__artist_albums') }}
),

genre_agg as (
    select
        artist_rowid,
        list(genre order by genre) as genres,
        count(*) as genre_count
    from artist_genres
    group by artist_rowid
),

track_stats as (
    select
        ta.artist_rowid,
        count(*) as track_count,
        avg(te.track_popularity) as avg_track_popularity,
        max(te.track_popularity) as max_track_popularity,
        avg(te.danceability) as avg_danceability,
        avg(te.energy) as avg_energy,
        avg(te.valence) as avg_valence,
        avg(te.tempo) as avg_tempo,
        min(te.release_year) as first_release_year,
        max(te.release_year) as last_release_year
    from track_artists ta
    inner join tracks_enriched te on ta.track_rowid = te.track_rowid
    group by ta.artist_rowid
),

album_stats as (
    select
        artist_rowid,
        count(*) as album_count
    from artist_albums
    group by artist_rowid
)

select
    a.artist_rowid,
    a.id as artist_id,
    a.name as artist_name,
    a.popularity as artist_popularity,
    a.followers_total,

    g.genres,
    g.genre_count,

    ts.track_count,
    ts.avg_track_popularity,
    ts.max_track_popularity,
    ts.avg_danceability,
    ts.avg_energy,
    ts.avg_valence,
    ts.avg_tempo,
    ts.first_release_year,
    ts.last_release_year,

    als.album_count

from artists a
left join genre_agg g on a.artist_rowid = g.artist_rowid
left join track_stats ts on a.artist_rowid = ts.artist_rowid
left join album_stats als on a.artist_rowid = als.artist_rowid

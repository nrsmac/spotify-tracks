with track_artists as (
    select * from {{ ref('stg__track_artists') }}
),

artists as (
    select * from {{ ref('stg__artists') }}
),

tracks_enriched as (
    select * from {{ ref('int__tracks_enriched') }}
),

artist_pairs as (
    select
        ta1.artist_rowid as artist_a_rowid,
        ta2.artist_rowid as artist_b_rowid,
        ta1.track_rowid
    from track_artists ta1
    inner join track_artists ta2
        on ta1.track_rowid = ta2.track_rowid
        and ta1.artist_rowid < ta2.artist_rowid
),

collaboration_stats as (
    select
        ap.artist_a_rowid,
        ap.artist_b_rowid,
        count(*) as shared_track_count,
        avg(te.track_popularity) as avg_track_popularity,
        min(te.release_year) as first_collab_year,
        max(te.release_year) as last_collab_year
    from artist_pairs ap
    inner join tracks_enriched te on ap.track_rowid = te.track_rowid
    group by ap.artist_a_rowid, ap.artist_b_rowid
)

select
    cs.artist_a_rowid,
    a.id as artist_a_id,
    a.name as artist_a_name,
    cs.artist_b_rowid,
    b.id as artist_b_id,
    b.name as artist_b_name,
    cs.shared_track_count,
    cs.avg_track_popularity,
    cs.first_collab_year,
    cs.last_collab_year

from collaboration_stats cs
inner join artists a on cs.artist_a_rowid = a.artist_rowid
inner join artists b on cs.artist_b_rowid = b.artist_rowid

with artist_genres as (
    select * from {{ ref('stg__artist_genres') }}
),

genres as (
    select * from {{ ref('mart__genres') }}
),

genre_pairs as (
    select
        g1.genre as genre_a,
        g2.genre as genre_b,
        count(distinct g1.artist_rowid) as shared_artist_count
    from artist_genres g1
    inner join artist_genres g2
        on g1.artist_rowid = g2.artist_rowid
        and g1.genre < g2.genre
    group by g1.genre, g2.genre
)

select
    gp.genre_a,
    gp.genre_b,
    gp.shared_artist_count,
    ga.artist_count as genre_a_artist_count,
    gb.artist_count as genre_b_artist_count,
    gp.shared_artist_count::float
        / (ga.artist_count + gb.artist_count - gp.shared_artist_count) as jaccard_similarity

from genre_pairs gp
inner join genres ga on gp.genre_a = ga.genre
inner join genres gb on gp.genre_b = gb.genre

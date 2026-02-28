-- Performance: pre-aggregates tracks and albums by available_markets_rowid (~89K groups)
-- before joining to unnested markets (~9M rows), avoiding a 9M × 256M fan-out join.
-- Uses sum/count to recompute weighted averages after the second GROUP BY.

with available_markets as (
    select * from {{ ref('stg__available_markets') }}
),

tracks as (
    select * from {{ ref('stg__tracks') }}
),

albums as (
    select * from {{ ref('stg__albums') }}
),

track_aggs_by_rowid as (
    select
        available_markets_rowid,
        count(*) as track_count,
        sum(popularity) as popularity_sum
    from tracks
    group by available_markets_rowid
),

album_aggs_by_rowid as (
    select
        available_markets_rowid,
        count(*) as album_count,
        sum(popularity) as popularity_sum
    from albums
    group by available_markets_rowid
),

track_markets as (
    select
        am.market_code,
        sum(ta.track_count) as track_count,
        sum(ta.popularity_sum) / nullif(sum(ta.track_count), 0) as avg_track_popularity
    from available_markets am
    inner join track_aggs_by_rowid ta on am.available_markets_rowid = ta.available_markets_rowid
    group by am.market_code
),

album_markets as (
    select
        am.market_code,
        sum(aa.album_count) as album_count,
        sum(aa.popularity_sum) / nullif(sum(aa.album_count), 0) as avg_album_popularity
    from available_markets am
    inner join album_aggs_by_rowid aa on am.available_markets_rowid = aa.available_markets_rowid
    group by am.market_code
)

select
    coalesce(tm.market_code, alm.market_code) as market_code,
    tm.track_count,
    tm.avg_track_popularity,
    alm.album_count,
    alm.avg_album_popularity

from track_markets tm
full outer join album_markets alm on tm.market_code = alm.market_code

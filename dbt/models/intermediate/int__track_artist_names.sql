-- Performance: extracted from mart__tracks to isolate the string_agg (348M rows, 256M groups)
-- from the subsequent 256M × 256M join in mart__tracks. Materializing as a separate table
-- lets each step execute independently within MotherDuck's memory limits.
-- Uses unordered string_agg — ordered variants (string_agg with ORDER BY, list_sort + list)
-- both failed on MotherDuck at this scale.

with track_artists as (
    select * from {{ ref('stg__track_artists') }}
),

artists as (
    select * from {{ ref('stg__artists') }}
)

select
    ta.track_rowid,
    string_agg(a.name, ', ') as artist_names,
    count(*) as artist_count
from track_artists ta
inner join artists a on ta.artist_rowid = a.artist_rowid
group by ta.track_rowid

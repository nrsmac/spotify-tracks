with source as (
    select * from {{ source('spotify_raw', 'raw__albums') }}
)

select
    rowid as album_rowid, -- renamed from `rowid`
    id, -- unique + not_null (schema.yml)
    epoch_ms(fetched_at) as fetched_at,
    name,
    album_type, -- accepted_values [single, album, compilation] (schema.yml)
    available_markets_rowid,
    external_id_upc,
    copyright_c,
    copyright_p,
    label,
    popularity, -- accepted_range 0–100 (schema.yml)
    release_date,
    release_date_precision, -- accepted_values [day, month, year] (schema.yml)
    -- parsed from release_date + release_date_precision (day→YYYY-MM-DD, month→YYYY-MM, year→YYYY)
    case
        when release_date is null then null
        when release_date like '0000%' then null
        when release_date_precision = 'day' then try_cast(release_date as date)
        when release_date_precision = 'month' then try_cast(release_date || '-01' as date)
        when release_date_precision = 'year' then try_cast(release_date || '-01-01' as date)
        else null
    end as release_date_parsed,
    -- flags ~14,400 rows with pre-1900 or bogus dates (13,177 have year "0000")
    (
        release_date like '0000%'
        or coalesce(try_cast(left(release_date, 4) as integer), 0) < 1900
    ) as is_bogus_date,
    (name is null or name = '') as is_name_empty, -- flags 8,609 rows with empty name
    total_tracks,
    external_id_amgid
from source
where rowid in {{ qualified_album_rowids() }}

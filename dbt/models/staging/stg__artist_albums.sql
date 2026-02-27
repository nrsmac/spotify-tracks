-- unique combination of (artist_rowid, album_rowid) (schema.yml)

with source as (
    select * from {{ source('spotify_raw', 'raw__artist_albums') }}
)

-- deduplicates ~66,500 duplicate (artist_rowid, album_rowid) pairs
select
    artist_rowid, -- relationships to stg__artists (schema.yml)
    album_rowid, -- relationships to stg__albums (schema.yml)
    is_appears_on::boolean as is_appears_on,
    is_implicit_appears_on::boolean as is_implicit_appears_on,
    index_in_album
from source
qualify row_number() over (partition by artist_rowid, album_rowid order by artist_rowid) = 1

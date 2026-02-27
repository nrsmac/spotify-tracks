-- unique combination of (track_rowid, artist_rowid) (schema.yml)

with source as (
    select * from {{ source('spotify_raw', 'raw__track_artists') }}
)

select distinct -- deduplicates 80 duplicate (track_rowid, artist_rowid) pairs
    track_rowid, -- relationships to stg__tracks (schema.yml)
    artist_rowid -- relationships to stg__artists (schema.yml)
from source

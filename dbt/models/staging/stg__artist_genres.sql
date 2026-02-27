with source as (
    select * from {{ source('spotify_raw', 'raw__artist_genres') }}
)

select
    artist_rowid, -- not_null (schema.yml)
    genre -- not_null (schema.yml)
from source

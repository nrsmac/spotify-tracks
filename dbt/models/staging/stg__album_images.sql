with source as (
    select * from {{ source('spotify_raw', 'raw__album_images') }}
)

select
    album_rowid, -- not_null (schema.yml)
    width, -- > 0 (schema.yml)
    height, -- > 0 (schema.yml)
    url
from source

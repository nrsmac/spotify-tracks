with source as (
    select * from {{ source('spotify_raw', 'raw__artist_redirects') }}
)

select
    from_id,
    to_id
from source

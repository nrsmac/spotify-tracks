with source as (
    select * from {{ source('spotify_raw', 'raw__track_files') }}
)

select
    rowid,
    track_id, -- unique (schema.yml)
    filename,
    reencoded_kbit_vbr,
    epoch_ms(fetched_at) as fetched_at,
    session_country,
    sha256_original,
    sha256_with_embedded_meta,
    status,
    isrc_has_download::boolean as isrc_has_download,
    track_popularity,
    secondary_priority,
    prefixed_ogg_packet,
    alternatives,
    file_id_ogg_vorbis_96,
    file_id_ogg_vorbis_160,
    file_id_ogg_vorbis_320,
    file_id_aac_24,
    language_of_performance,
    artist_roles,
    has_lyrics::boolean as has_lyrics,
    licensor,
    original_title,
    version_title,
    file_id_mp3_96,
    content_ratings,
    filesize_bytes
from source

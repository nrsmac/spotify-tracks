{% macro qualified_artist_rowids() %}
(
    select rowid
    from {{ source('spotify_raw', 'raw__artists') }}
    where popularity >= {{ var('min_artist_popularity', 20) }}
)
{% endmacro %}

{% macro qualified_track_rowids() %}
(
    select distinct track_rowid
    from {{ source('spotify_raw', 'raw__track_artists') }}
    where artist_rowid in {{ qualified_artist_rowids() }}
)
{% endmacro %}

{% macro qualified_album_rowids() %}
(
    select distinct album_rowid
    from {{ source('spotify_raw', 'raw__artist_albums') }}
    where artist_rowid in {{ qualified_artist_rowids() }}
)
{% endmacro %}

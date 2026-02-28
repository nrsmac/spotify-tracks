-- Performance: splits the original single 3-way join (curator_playlists × playlist_tracks
-- × tracks_enriched) into two independent aggregation paths to stay within memory limits.
--
-- Part A (unique_track_count): lean 2-table join avoids pulling in the wide tracks_enriched
--   table just to count distinct tracks per owner.
--
-- Part B (avg audio stats): two-phase aggregation — first rolls up 1.7B playlist_tracks to
--   ~6.6M playlist-level sums/counts, then joins the small result to curator_playlists and
--   recomputes weighted averages per owner. Avoids materializing the full 3-way join.

with playlists as (
    select * from {{ ref('stg__playlists') }}
),

playlist_tracks as (
    select * from {{ ref('stg__playlist_tracks') }}
),

tracks_enriched as (
    select * from {{ ref('int__tracks_enriched') }}
),

curator_playlists as (
    select
        playlist_rowid,
        owner_id,
        owner_display_name,
        followers_total
    from playlists
    where not is_missing_owner
),

curator_summary as (
    select
        owner_id,
        arg_max(owner_display_name, followers_total) as owner_display_name,
        count(*) as playlist_count,
        sum(followers_total) as total_followers
    from curator_playlists
    group by owner_id
),

-- Part A: unique track count (2-table join only)
curator_unique_tracks as (
    select
        owner_id,
        count(*) as unique_track_count
    from (
        select distinct cp.owner_id, pt.track_rowid
        from curator_playlists cp
        inner join playlist_tracks pt on cp.playlist_rowid = pt.playlist_rowid
    )
    group by owner_id
),

-- Part B, Phase 1: aggregate audio stats per playlist
playlist_audio_stats as (
    select
        pt.playlist_rowid,
        count(*) as track_count,
        sum(te.track_popularity) as sum_track_popularity,
        sum(te.danceability) filter (where te.has_audio_features) as sum_danceability,
        sum(te.energy) filter (where te.has_audio_features) as sum_energy,
        sum(te.valence) filter (where te.has_audio_features) as sum_valence,
        count(*) filter (where te.has_audio_features) as audio_feature_count
    from playlist_tracks pt
    inner join tracks_enriched te on pt.track_rowid = te.track_rowid
    group by pt.playlist_rowid
),

-- Part B, Phase 2: roll up to owner level
curator_audio_stats as (
    select
        cp.owner_id,
        sum(pas.sum_track_popularity) / nullif(sum(pas.track_count), 0) as avg_track_popularity,
        sum(pas.sum_danceability) / nullif(sum(pas.audio_feature_count), 0) as avg_danceability,
        sum(pas.sum_energy) / nullif(sum(pas.audio_feature_count), 0) as avg_energy,
        sum(pas.sum_valence) / nullif(sum(pas.audio_feature_count), 0) as avg_valence
    from curator_playlists cp
    inner join playlist_audio_stats pas on cp.playlist_rowid = pas.playlist_rowid
    group by cp.owner_id
)

select
    cs.owner_id,
    cs.owner_display_name,
    cs.playlist_count,
    cs.total_followers,

    cut.unique_track_count,
    cas.avg_track_popularity,
    cas.avg_danceability,
    cas.avg_energy,
    cas.avg_valence

from curator_summary cs
left join curator_unique_tracks cut on cs.owner_id = cut.owner_id
left join curator_audio_stats cas on cs.owner_id = cas.owner_id

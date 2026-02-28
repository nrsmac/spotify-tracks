# spotify_tracks dbt project

Transforms raw Spotify API data into analytics-ready tables on MotherDuck. The raw data covers tracks, albums, artists, playlists, and audio features extracted from Spotify's Web API.

## Architecture

The project follows a three-layer approach:

| Layer | Schema | Materialization | Count |
|---|---|---|---|
| **Staging** | `staging` | views | 15 models |
| **Intermediate** | `intermediate` | table | 1 model |
| **Marts** | `marts` | tables | 9 models |

## Model overview

### Staging

Clean, deduplicated views over the `raw` source tables. Key transformations include filtering zero-duration tracks, casting booleans, parsing dates, and converting epoch timestamps.

| Group | Models |
|---|---|
| Core entities | `stg__tracks`, `stg__albums`, `stg__artists`, `stg__playlists` |
| Junctions | `stg__track_artists`, `stg__artist_albums`, `stg__artist_genres`, `stg__playlist_tracks`, `stg__artist_redirects` |
| Audio features | `stg__track_audio_features`, `stg__track_files` |
| Images | `stg__album_images`, `stg__artist_images`, `stg__playlist_images` |
| Markets | `stg__available_markets` |

### Intermediate

**`int__tracks_enriched`** — Pre-joins tracks with albums and audio features into a single denormalized table. Adds derived columns like `release_year`, `release_decade`, and `has_audio_features`. Used by most mart models to avoid repeated joins.

### Marts

Wide, analytics-ready tables built for querying.

| Model | Description |
|---|---|
| `mart__tracks` | One row per track with artist names, album metadata, and all audio features |
| `mart__artists` | One row per artist with genre list, follower count, track/album stats, and avg audio features |
| `mart__albums` | One row per album with artist names, track counts, total duration, and avg audio features |
| `mart__genres` | One row per genre with artist/track counts, popularity, and avg audio feature profile |
| `mart__genre_cooccurrence` | Genre pairs that share artists, with Jaccard similarity scores |
| `mart__labels` | Label performance by year — track/album counts, popularity, and audio feature averages |
| `mart__markets` | Market-level track and album availability with avg popularity |
| `mart__curators` | Playlist curators with follower totals, track counts, and avg audio features |
| `mart__collaborations` | Artist pairs that share tracks, with collaboration frequency and date range |

## DAG

```
raw.*
 └─► staging (15 views)
      ├─► int__tracks_enriched (table)
      │    ├─► mart__tracks
      │    ├─► mart__artists
      │    ├─► mart__albums
      │    ├─► mart__genres
      │    ├─► mart__labels
      │    ├─► mart__curators
      │    └─► mart__collaborations
      ├─► mart__genre_cooccurrence
      └─► mart__markets
```

## Usage

```bash
dbt run          # build all models
dbt test         # run tests
dbt build        # run + test in DAG order
dbt run -s marts # build only the marts layer
```

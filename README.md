# Spotify Tracks

Analysis of the [Anna's Archive Spotify 2025-07 metadata backup](https://annas-archive.org/datasets/spotify_2025_07) — a snapshot of Spotify's public catalog API covering **256M tracks, 58M albums, 15M artists, 768 genres, and 6.6M playlists** with 1.7B playlist-track entries. 

Raw data lives in MotherDuck at `spotify.raw` (15 tables). dbt models in `dbt/` build staging and mart layers on top of it.

## Schema Overview

### Core Entities

| Table | Rows | Key Columns |
|-------|-----:|-------------|
| `tracks` | 256,039,007 | `id`, `name`, `album_rowid`, `popularity`, `duration_ms`, `explicit`, `external_id_isrc` |
| `albums` | 58,590,982 | `id`, `name`, `album_type`, `label`, `popularity`, `release_date`, `total_tracks` |
| `artists` | 15,430,442 | `id`, `name`, `followers_total`, `popularity` |
| `playlists` | 6,608,769 | `id`, `name`, `description`, `owner_id`, `owner_display_name`, `followers_total`, `collaborative`, `public` |

### Junction / Relationship Tables

| Table | Rows | Description |
|-------|-----:|-------------|
| `playlist_tracks` | 1,698,443,099 | Links playlists to tracks (position, `added_at`, `added_by_id`) |
| `track_artists` | 348,055,756 | Links tracks to artists |
| `artist_albums` | 111,808,828 | Links artists to albums (`is_appears_on`, `index_in_album`) |
| `artist_genres` | 2,229,947 | Maps artists to genre strings (768 distinct genres) |
| `available_markets` | 89,501 | Distinct market-list combinations referenced by tracks and albums |
| `artist_redirects` | 3,974 | Maps retired artist IDs to current ones |

### Audio Features & Files

| Table | Rows | Key Columns |
|-------|-----:|-------------|
| `track_audio_features` | 255,594,909 | `danceability`, `energy`, `loudness`, `speechiness`, `acousticness`, `instrumentalness`, `liveness`, `valence`, `tempo`, `key`, `mode`, `time_signature` |
| `track_files` | 255,966,403 | `filename`, `sha256_original`, `filesize_bytes`, `session_country`, `isrc_has_download`, `has_lyrics` |

### Images

| Table | Rows | Description |
|-------|-----:|-------------|
| `album_images` | 175,809,992 | Album artwork URLs with `width`/`height` |
| `artist_images` | 26,777,840 | Artist photo URLs with `width`/`height` |
| `playlist_images` | 11,326,423 | Playlist cover URLs with `width`/`height` |

## Mart Models

The dbt project builds 9 analytics-ready tables in `spotify.marts`:

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

See [`dbt/README.md`](dbt/README.md) for the full model architecture (staging, intermediate, and mart layers).

## Research Questions & Dashboard Ideas

**Genre landscape** — Top genres by artist count; genre co-occurrence networks (artists tagged with multiple genres); genre popularity vs. average follower count.

**Audio feature trends over time** — Average danceability, energy, and valence by release year; how tempo and loudness have shifted decade-over-decade.

**Popularity drivers** — Correlation between audio features and track popularity; explicit content vs. popularity; does duration affect popularity?

**Release patterns** — Albums released per year/month; single vs. album vs. compilation breakdown over time (`album_type`); label market share.

**Artist analysis** — Power-law distribution of `followers_total`; most prolific artists by track count; label concentration across top artists.

**Playlist ecosystem** — Playlist size distributions (`tracks_total`); collaborative vs. public playlists; top curators by playlist count and total followers.

**Market availability** — Geographic distribution of content via `available_markets`; tracks exclusive to few markets vs. globally available.

## Dive Ideas

**Audio Feature Comparison**: Compare audio feature profiles between songs, across an artist's career between albums, etc. Radar charts of danceability, energy, valence, acousticness, etc. side-by-side.

**Genre Galaxy**: Explore all 768 genres as a network — nodes sized by artist count, edges drawn when artists share multiple genres. Click a genre to see its top artists, average audio features, and related genres. Filter by popularity or follower thresholds.

**Label Market Share Over Time**: Stacked area chart of the top N labels by album count per release year. Click a label to drill into its artist roster, genre mix, and popularity distribution. See which labels dominate each decade.

**Playlist Curator Leaderboard**: Rank playlist owners by total follower reach, playlist count, and track diversity. Click a curator to see their playlist portfolio — genres covered, average track popularity, and collaborative vs. solo playlists.

**What Makes a Hit?**: Scatter plots of audio features (energy, danceability, tempo, valence) vs. track popularity. Filter by decade, genre, or explicit flag. Surface the audio "recipe" that correlates with high popularity in different eras.

**Artist Career Arc**: Pick an artist and see how their sound evolves album-by-album — audio feature trends (getting louder? more danceable?), popularity trajectory, release cadence, and label changes over time.

**Global Availability Map**: Choropleth showing how many tracks are available per market. Drill in to see which genres or labels skew toward specific regions. Find tracks exclusive to a handful of countries.

**The Tempo & Key of Music**: Distribution of tempos, keys, and modes across the entire 256M-track catalog. Filter by genre to see that EDM clusters around 128 BPM while hip-hop sits at 80-90. Heatmap of key × mode colored by average valence.

**Explicit Content Over the Decades**: Track the share of explicit tracks by release year. Break down by genre to see where explicit content is rising fastest. Compare explicit vs. clean versions' popularity.

**Collaboration Network**: Start from any artist and explore their collaborators (via shared tracks). See how many degrees of separation exist between artists, which artists are the biggest "connectors," and how collaboration patterns differ across genres.

## Setup

This project uses [uv](https://docs.astral.sh/uv/) for Python dependency management. Install it first:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Then set up the project:

```bash
cp .env.example .env
# Edit .env with your actual values

uv sync  # install Python dependencies
```

AWS credentials must be available via the [credential provider chain](https://docs.aws.amazon.com/sdkref/latest/guide/standardized-credentials.html) (environment variables, `~/.aws/credentials`, IAM role, etc.).

## Usage

### Run the pipeline locally

```bash
make pipeline    # download, extract, upload
```

Or individual stages:

```bash
make download    # download zip from Kaggle
make extract     # extract to data/extracted/
make upload      # sync to S3
make load-to-md      # load tables to MotherDuck
```

### Load into MotherDuck

Loads all 19 tables from S3 into the `spotify.raw` schema in MotherDuck. Requires the [DuckDB CLI](https://duckdb.org/docs/installation/) and a MotherDuck account (`duckdb md:` triggers auth on first use).

```bash
make load-to-md
```

### Run dbt models

```bash
# Install dependencies (from the repo root)
uv sync

# Verify MotherDuck connection
uv run dbt debug --profiles-dir dbt

# Run models
uv run dbt run --profiles-dir dbt
```

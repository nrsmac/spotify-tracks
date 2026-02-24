-- Load Spotify data from S3 into MotherDuck
-- Usage: S3_BUCKET=<bucket> envsubst < load_to_motherduck.sql | duckdb md:

INSTALL httpfs;
LOAD httpfs;

SET s3_region = 'us-east-1';

CREATE SECRET IF NOT EXISTS s3_access (
  TYPE s3,
  PROVIDER credential_chain
);

.print Setting up database and schema...
CREATE DATABASE IF NOT EXISTS spotify;
CREATE SCHEMA IF NOT EXISTS spotify.raw;

.print [ 1/19] Loading album_images...
CREATE OR REPLACE TABLE spotify.raw.album_images AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_parquet/album_images.parquet');

.print [ 2/19] Loading albums...
CREATE OR REPLACE TABLE spotify.raw.albums AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_parquet/albums.parquet');

.print [ 3/19] Loading artist_albums...
CREATE OR REPLACE TABLE spotify.raw.artist_albums AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_parquet/artist_albums.parquet');

.print [ 4/19] Loading artist_genres...
CREATE OR REPLACE TABLE spotify.raw.artist_genres AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_parquet/artist_genres.parquet');

.print [ 5/19] Loading artist_images...
CREATE OR REPLACE TABLE spotify.raw.artist_images AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_parquet/artist_images.parquet');

.print [ 6/19] Loading artists...
CREATE OR REPLACE TABLE spotify.raw.artists AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_parquet/artists.parquet');

.print [ 7/19] Loading available_markets...
CREATE OR REPLACE TABLE spotify.raw.available_markets AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_parquet/available_markets.parquet');

.print [ 8/19] Loading track_artists...
CREATE OR REPLACE TABLE spotify.raw.track_artists AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_parquet/track_artists.parquet');

.print [ 9/19] Loading tracks...
CREATE OR REPLACE TABLE spotify.raw.tracks AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_parquet/tracks.parquet');

.print [10/19] Loading track_audio_features...
CREATE OR REPLACE TABLE spotify.raw.track_audio_features AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_audio_features_parquet/track_audio_features.parquet');

.print [11/19] Loading playlist_images...
CREATE OR REPLACE TABLE spotify.raw.playlist_images AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_playlists_parquet/playlist_images.parquet');

.print [12/19] Loading playlist_tracks...
CREATE OR REPLACE TABLE spotify.raw.playlist_tracks AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_playlists_parquet/playlist_tracks.parquet');

.print [13/19] Loading playlists...
CREATE OR REPLACE TABLE spotify.raw.playlists AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_playlists_parquet/playlists.parquet');

.print [14/19] Loading track_files...
CREATE OR REPLACE TABLE spotify.raw.track_files AS
  SELECT * FROM read_parquet('s3://${S3_BUCKET}/raw/spotify_clean_track_files_parquet/track_files.parquet');

.print [15/19] Loading artist_redirects...
CREATE OR REPLACE TABLE spotify.raw.artist_redirects AS
  SELECT * FROM read_json_auto('s3://${S3_BUCKET}/raw/spotify_artist_redirects.json');

.print [16/19] Loading audiobook_chapters...
CREATE OR REPLACE TABLE spotify.raw.audiobook_chapters AS
  SELECT * FROM read_json_auto('s3://${S3_BUCKET}/raw/spotify_audiobook_chapters.jsonl.zst', format='newline_delimited', compression='zstd', union_by_name=true);

.print [17/19] Loading audiobooks...
CREATE OR REPLACE TABLE spotify.raw.audiobooks AS
  SELECT * FROM read_json_auto('s3://${S3_BUCKET}/raw/spotify_audiobooks.jsonl.zst', format='newline_delimited', compression='zstd', union_by_name=true);

.print [18/19] Loading show_episodes...
CREATE OR REPLACE TABLE spotify.raw.show_episodes AS
  SELECT * FROM read_json_auto('s3://${S3_BUCKET}/raw/spotify_show_episodes.jsonl.zst', format='newline_delimited', compression='zstd', union_by_name=true);

.print [19/19] Loading shows...
CREATE OR REPLACE TABLE spotify.raw.shows AS
  SELECT * FROM read_json_auto('s3://${S3_BUCKET}/raw/spotify_shows.jsonl.zst', format='newline_delimited', compression='zstd', union_by_name=true);

.print All 19 tables loaded into spotify.raw

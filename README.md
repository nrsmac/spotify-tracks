# Spotify Tracks

Spotify metadata dataset from [Anna's Archive on Kaggle](https://www.kaggle.com/datasets/lordpatil/spotify-metadata-by-annas-archive), loaded into S3 for analysis.

## Architecture

**Ingestion**: The dataset (~100GB+ compressed) is downloaded, extracted, and uploaded to S3.
=======
The dataset (~100GB+ compressed) is downloaded, extracted, and uploaded to S3, then loaded into MotherDuck for analysis.

## Setup

```bash
cp .env.example .env
# Edit .env with your actual values
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
```

### Load into MotherDuck

Loads all 19 tables from S3 into the `spotify.raw` schema in MotherDuck. Requires the [DuckDB CLI](https://duckdb.org/docs/installation/) and a MotherDuck account (`duckdb md:` triggers auth on first use).

```bash
make load-to-md
```

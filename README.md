# Spotify Tracks

Spotify metadata dataset from [Anna's Archive on Kaggle](https://www.kaggle.com/datasets/lordpatil/spotify-metadata-by-annas-archive), loaded into S3 for analysis.

## Architecture

The dataset (~100GB+ compressed) is downloaded, extracted, and uploaded to S3.

```
Kaggle --curl--> EC2 (t3.micro, 500GB gp3) --s3 sync--> S3 bucket
```

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
make clean       # remove local data files
```

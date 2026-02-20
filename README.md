# Spotify Tracks

Spotify metadata dataset from [Anna's Archive on Kaggle](https://www.kaggle.com/datasets/lordpatil/spotify-metadata-by-annas-archive), loaded into S3 for analysis.

## Architecture

The dataset (~100GB+ compressed) is downloaded, extracted, and uploaded to S3 via a temporary EC2 instance — used instead of downloading locally due to a slow home network connection.

```
Kaggle --curl--> EC2 (t3.micro, 500GB gp3) --s3 sync--> S3 bucket
```

Infrastructure is managed with OpenTofu. The EC2 instance is provisioned with a `user_data` script that places a `pipeline.sh` script in the ec2-user home directory. SSH in and run it to kick off the download, extract, and upload. Once the data is in S3, the instance can be destroyed — the S3 bucket is protected from deletion via `lifecycle { prevent_destroy = true }`.

## Usage

### Provision infrastructure
Make sure AWS credentials are configured and `AWS_PROFILE` is set if you're using SSO profiles.

```bash
cd terraform
tofu apply
```

### Run the pipeline on EC2

```bash
# SSH into the instance
$(tofu output -raw ssh_command)

# run the pipeline script (placed by user_data)
./pipeline.sh
```

The script will:
1. Download the dataset zip from Kaggle
2. Extract it to `/tmp`
3. Upload the extracted files to S3
4. Clean up local files

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

### Tear down the instance

Once the data is in S3, destroy the EC2 instance to stop costs:

```bash
cd terraform
tofu destroy \
  -target=aws_instance.spotify_uploader \
  -target=aws_security_group.ec2 \
  -target=aws_iam_instance_profile.ec2_s3_upload \
  -target=aws_iam_role_policy.s3_upload \
  -target=aws_iam_role.ec2_s3_upload \
  -target=data.aws_ami.amazon_linux
```

The S3 bucket and its public access block are retained (`prevent_destroy = true`).

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "spotify_metadata" {
  bucket = "noah-annasarchive-spotify-metadata"

  tags = {
    Name        = "Spotify Metadata Bucket"
    Environment = "Production"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "spotify_metadata" {
  bucket = aws_s3_bucket.spotify_metadata.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle {
    prevent_destroy = true
  }
}

# --- IAM role for EC2 to upload to the S3 bucket ---

resource "aws_iam_role" "ec2_s3_upload" {
  name = "spotify-ec2-s3-upload"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "s3_upload" {
  name = "s3-upload-to-spotify-metadata"
  role = aws_iam_role.ec2_s3_upload.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:ListBucket",
      ]
      Resource = [
        aws_s3_bucket.spotify_metadata.arn,
        "${aws_s3_bucket.spotify_metadata.arn}/*",
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_s3_upload" {
  name = "spotify-ec2-s3-upload"
  role = aws_iam_role.ec2_s3_upload.name
}

# --- EC2 instance ---

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "ec2" {
  name        = "spotify-ec2-sg"
  description = "Security group for Spotify data EC2 instance"
  vpc_id      = "vpc-088c2ad33af98036e"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "spotify_uploader" {
  ami                  = data.aws_ami.amazon_linux.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_s3_upload.name
  key_name             = var.key_pair_name
  subnet_id            = "subnet-0c2ee0af2f85da286"

  vpc_security_group_ids = [aws_security_group.ec2.id]

  root_block_device {
    volume_size = 500
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash
    cat > /home/ec2-user/pipeline.sh << 'SCRIPT'
    #!/bin/bash
    set -euo pipefail

    DATASET_URL="https://www.kaggle.com/api/v1/datasets/download/lordpatil/spotify-metadata-by-annas-archive"
    DATASET_ZIP="/tmp/spotify-metadata-by-annas-archive.zip"
    EXTRACT_DIR="/tmp/spotify-metadata"
    S3_BUCKET="s3://${aws_s3_bucket.spotify_metadata.id}"

    echo "Downloading dataset..."
    curl -L -o "$DATASET_ZIP" "$DATASET_URL"

    echo "Extracting dataset..."
    mkdir -p "$EXTRACT_DIR"
    unzip -o "$DATASET_ZIP" -d "$EXTRACT_DIR"

    echo "Uploading to S3..."
    aws s3 sync "$EXTRACT_DIR/" "$S3_BUCKET/" --only-show-errors

    echo "Cleaning up..."
    rm -rf "$DATASET_ZIP" "$EXTRACT_DIR"

    echo "Done."
    SCRIPT
    chown ec2-user:ec2-user /home/ec2-user/pipeline.sh
    chmod +x /home/ec2-user/pipeline.sh
  EOF

  tags = {
    Name = "spotify-data-uploader"
  }
}

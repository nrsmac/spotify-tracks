output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.spotify_metadata.id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.spotify_uploader.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.spotify_uploader.public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.spotify_uploader.public_ip}"
}

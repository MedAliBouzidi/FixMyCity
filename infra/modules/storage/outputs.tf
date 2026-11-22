output "media_bucket_name" {
  value = aws_s3_bucket.media.bucket
}

output "media_bucket_arn" {
  value = aws_s3_bucket.media.arn
}

output "media_bucket_regional_domain_name" {
  value = aws_s3_bucket.media.bucket_regional_domain_name
}

output "archives_bucket_name" {
  value = aws_s3_bucket.archives.bucket
}

output "archives_bucket_arn" {
  value = aws_s3_bucket.archives.arn
}

output "archives_bucket_policy_dependency" {
  description = "Permet à l'ALB d'attendre la policy avant d'activer les access logs"
  value       = aws_s3_bucket_policy.archives.id
}
output "database_endpoint" {
  value = module.main.database_endpoint
}

output "bucket_name" {
  value = module.main.bucket_name
}

output "domain_name" {
  value = module.main.cloudfront
}

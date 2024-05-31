variable "ssh_key_name" {
  description = "Name of the SSH key pair"
  default     = "online-shop-instance-key"
}

variable "ec2_instance_type" {
  description = "Instance type for EC2 instances"
  default     = "t2.micro"
}

variable "rds_instance_type" {
  description = "Instance type for RDS"
  default     = "db.t3.micro"
}

variable "image_tag" {
  description = "Docker image tag"
  default     = "latest"
}


locals {
  db_url                         = "jdbc:postgresql://test.cx862c4ee62q.us-east-1.rds.amazonaws.com/postgres"
  repo_url                       = aws_ecr_repository.this.repository_url
  ec2_container_service_role_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  task_exec_role                 = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  lambda_basic_policy            = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  lambda_basic_sqs_policy        = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  admin_role                     = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "database_endpoint" {
  value = aws_db_instance.online_shop_db.endpoint
}

output "bucket_name" {
  value = aws_s3_bucket.this.bucket_domain_name
}

output "cloudfront" {
  value = aws_cloudfront_distribution.this.domain_name
}

variable "project_name" {
  type    = string
  default = "test"
}

variable "application_port" {
  type    = number
  default = 8080
}

variable "database_port" {
  type    = string
  default = "5432"
}

variable "databse_engine" {
  type    = string
  default = "postgres"
}

variable "databse_engine_version" {
  type    = string
  default = "15.5"
}

variable "databse_name" {
  type    = string
  default = "postgres"
}

variable "databse_username" {
  type    = string
  default = "postgres"
}

variable "databse_password" {
  type    = string
  default = "postgres"
}

variable "environment_variables" {
  description = "List of environment variables for the application"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "SPRING_DATASOURCE_URL"
      value = "jdbc:postgresql://test.cx862c4ee62q.us-east-1.rds.amazonaws.com/postgres"
    },
    {
      name  = "SPRING_DATASOURCE_USERNAME"
      value = "postgres"
    },
    {
      name  = "SPRING_DATASOURCE_PASSWORD"
      value = "postgres"
    }
  ]
}

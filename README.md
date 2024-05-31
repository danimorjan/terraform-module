# terraform-module
A terraform module to provision resources for your infrastructure on AWS

## Terraform Module: Main

This Terraform module provisions the resources needed to deploy a Docker application in AWS ECS and front it using S3 with CloudFront. It also creates a VPC, security groups, and the necessary IAM roles.

### Table of Contents
- [Usage](#usage)
- [Input Variables](#input-variables)
- [Outputs](#outputs)
- [Requirements](#requirements)
- [Providers](#providers)
- [Description](#description)
- [License](#license)
- [Contributing](#contributing)
- [Authors](#authors)

## Usage

```hcl
module "main" {
  source                 = "./resources"
  project_name           = "test"
  application_port       = 8080
  database_port          = "5432"
  databse_engine         = "postgres"
  databse_engine_version = "15.5"
  databse_name           = "postgres"
  databse_username       = "postgres"
  databse_password       = "postgres"
  environment_variables = [
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


## Input Variables

| Name                    | Description                                | Type   | Default | Required |
|-------------------------|--------------------------------------------|--------|---------|----------|
| `project_name`          | The name of the project.                   | string | n/a     | yes      |
| `application_port`      | The port on which the application runs.    | number | n/a     | yes      |
| `database_port`         | The port on which the database runs.       | string | n/a     | yes      |
| `databse_engine`        | The type of database engine.               | string | n/a     | yes      |
| `databse_engine_version`| The version of the database engine.        | string | n/a     | yes      |
| `databse_name`          | The name of the database.                  | string | n/a     | yes      |
| `databse_username`      | The username for the database.             | string | n/a     | yes      |
| `databse_password`      | The password for the database.             | string | n/a     | yes      |
| `environment_variables` | Environment variables for the application. | list   | n/a     | yes      |

## Outputs

| Name                     | Description                                |
|--------------------------|--------------------------------------------|
| `database_endpoint`      | The endpoint of the provisioned database.  |
| `cloudfront_domain_name` | The domain name of the CloudFront distribution. |


## Requirements

- Terraform 0.12+
- AWS Provider

## Description

This module provisions the necessary resources to deploy a Docker application on AWS ECS. The front end is hosted on S3 and distributed using CloudFront. It also sets up an RDS PostgreSQL database for the application. The module creates a VPC, security groups, and the necessary IAM roles. Additionally, it configures environment variables required for the application to connect to the database.

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

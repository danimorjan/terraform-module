resource "aws_ecr_repository" "this" {
  name = var.project_name

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = var.project_name

  tags = {
    Project = var.project_name
  }
}



resource "aws_ecs_cluster" "this" {
  name = var.project_name

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.name
      }
    }
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_ecs_task_definition" "this" {
  family = var.project_name
  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = "${aws_ecr_repository.this.repository_url}:${var.image_tag}"
      essential = true,
      portMappings = [
        {
          containerPort = "${var.application_port}"
          hostPort      = "${var.application_port}"
        }
      ]
      environment = var.environment_variables,

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "${aws_cloudwatch_log_group.this.id}"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "shop-container"
        }
      }
    }
    ]
  )
  network_mode       = "bridge"
  execution_role_arn = aws_iam_role.ecs_task_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role_advanced.arn
  cpu                = 512
  memory             = 768
}

resource "aws_ecs_service" "this" {
  name                 = var.project_name
  cluster              = aws_ecs_cluster.this.id
  task_definition      = aws_ecs_task_definition.this.arn
  desired_count        = 1
  force_new_deployment = true

  # network_configuration {
  #   subnets          = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  #   security_groups  = [aws_security_group.ecs_task.id]
  # }
  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "${var.project_name}-container"
    container_port   = "${var.application_port}"
  }
}



resource "aws_iam_role" "ec2_pull_ecr_role" {
  name = "ec2-push-to-ecr-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_pull_policy_attachment" {
  role       = aws_iam_role.ec2_pull_ecr_role.name
  policy_arn = aws_iam_policy.allow_ec2_pull.arn
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskrole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = local.task_exec_role
}

resource "aws_iam_role_policy_attachment" "ecs_task_ssm_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_role" "ecs_task_role_advanced" {
  name = "ecsTaskroleAdvanced"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Project = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRoleAdvanced_policy" {
  role       = aws_iam_role.ecs_task_role_advanced.name
  policy_arn = local.task_exec_role
}

resource "aws_iam_role_policy_attachment" "ecs_task_ssm_advanced_attachment" {
  role       = aws_iam_role.ecs_task_role_advanced.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_logging_monitoring_attachment" {
  role       = aws_iam_role.ecs_task_role_advanced.name
  policy_arn = aws_iam_policy.logging_monitoring_policy.arn
}


resource "aws_iam_role" "ec2_ecs_role" {
  name = "ec2-ecr-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ecs_policy" {
  role       = aws_iam_role.ec2_ecs_role.name
  policy_arn = local.ec2_container_service_role_arn
}

resource "aws_iam_role" "lambda_role" {
  name = "lambdaExecutionRole"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy" {
  policy_arn = local.lambda_basic_policy
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_basic_sqs_queue_execution_policy" {
  policy_arn = local.lambda_basic_sqs_policy
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_basic_ses_send_policy" {
  policy_arn = aws_iam_policy.lambda_ses_policy.arn
  role       = aws_iam_role.lambda_role.name
}

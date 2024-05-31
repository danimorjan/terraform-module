

resource "aws_iam_instance_profile" "this" {
  name = "ec2-ecs-profile"
  role = aws_iam_role.ec2_ecs_role.name
}


data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "this" {
  name_prefix   = var.project_name
  image_id      = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type = var.ec2_instance_type
  # key_name      = var.ssh_key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }
  vpc_security_group_ids = [aws_security_group.allow_tcp.id]

  user_data = base64encode(templatefile("${path.module}/ecsuserdata.tftpl", {}))
}

resource "aws_autoscaling_group" "this" {
  name = var.project_name
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  vpc_zone_identifier = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  min_size            = 1
  desired_capacity    = 1
  max_size            = 2
  health_check_type   = "ELB"
  #target_group_arns   = [aws_lb_target_group.shop_target_group.arn]
}


resource "aws_lb_target_group" "this" {
  name     = var.project_name
  port     = var.application_port
  protocol = "HTTP"
  # target_type = "ip"
  vpc_id = aws_vpc.this.id

  health_check {
    path     = "/health"
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb" "this" {
  name               = var.project_name
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  security_groups    = [aws_security_group.online_shop_alb.id]

  enable_deletion_protection = false

  tags = {
    Project = var.project_name
  }
}


resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_ecs_capacity_provider" "this" {
  name = var.project_name

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.this.arn

    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}


resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.this.name
  }
}


resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Project = var.project_name
  }

}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Project = var.project_name
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Project = var.project_name
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "true"

  tags = {
    Project = var.project_name
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_route_table_association" "public_subnet1_association" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet2_association" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Project = var.project_name
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Project = var.project_name
  }

}

resource "aws_security_group" "allow_tcp" {
  name        = var.project_name
  description = "Allow TCP inbound traffic on port .... and all outbound traffic"
  vpc_id      = aws_vpc.this.id

  tags = {
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  security_group_id = aws_security_group.allow_tcp.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = "${var.application_port}"
  ip_protocol       = "tcp"
  to_port           = "${var.application_port}"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tcp.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "db" {
  name = "${var.project_name}_db"


  description = "Security group for online shop database"
  vpc_id      = aws_vpc.this.id

  tags = {
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_db" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.allow_tcp.id
  from_port                    = var.database_port
  ip_protocol                  = "tcp"
  to_port                      = var.database_port
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_db_for_ecs_sg" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.ecs_task.id
  from_port                    = var.database_port
  ip_protocol                  = "tcp"
  to_port                      = var.database_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_db" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_security_group" "online_shop_alb" {
  name        = "${var.project_name}_alb"
  description = "Security group for online shop alb"
  vpc_id      = aws_vpc.this.id

  tags = {
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tcp_80_all" {
  security_group_id = aws_security_group.online_shop_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_alb" {
  security_group_id = aws_security_group.online_shop_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "ecs_task" {
  name        = "${var.project_name}_ecs"
  description = "Security group for ecs"
  vpc_id      = aws_vpc.this.id

  tags = {
    Project = var.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_from_inside_vpc" {
  security_group_id = aws_security_group.ecs_task.id
  cidr_ipv4         = aws_vpc.this.cidr_block
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_ecs" {
  security_group_id = aws_security_group.ecs_task.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_instance" "online_shop_db" {
  identifier                  = var.project_name
  allocated_storage           = 20
  engine                      = var.databse_engine
  engine_version              = var.databse_engine_version
  allow_major_version_upgrade = true
  instance_class              = var.rds_instance_type
  db_name                     = var.databse_name
  username                    = var.databse_username
  apply_immediately           = true
  skip_final_snapshot         = true
  password                    = var.databse_password
  db_subnet_group_name        = aws_db_subnet_group.online_shop_subnet_group.name
  vpc_security_group_ids      = [aws_security_group.db.id]
  multi_az                    = false


  tags = {
    Project = var.project_name
  }
}



resource "aws_db_subnet_group" "online_shop_subnet_group" {
  name       = "${var.project_name}-subnet-group"
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  tags = {
    Project = var.project_name
  }
}


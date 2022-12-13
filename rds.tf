resource "aws_db_instance" "rds_postgres" {
  identifier             = "${var.project_name}-${terraform.workspace}-rds-postgres-${random_id.name.hex}"
  instance_class         = "db.t3.micro"
  allocated_storage      = 200
  max_allocated_storage  = 1000
  engine                 = "postgres"
  engine_version         = "14.5"
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.rds_postgres_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_postgres_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  #   lifecycle {
  #     ignore_changes = [
  #       password
  #     ]
  #   }

}

resource "aws_db_subnet_group" "rds_postgres_subnet_group" {
  name       = "${var.project_name}-${terraform.workspace}-rds-postgres-subnet-group-${random_id.name.hex}"
  subnet_ids = [aws_subnet.vpc_private_subnet_1.id, aws_subnet.vpc_private_subnet_2.id]

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-rds-postgres-subnet-group-${random_id.name.hex}"
  }
}

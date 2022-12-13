resource "aws_security_group" "bastion_host_sg" {
  name        = "${var.project_name}-${terraform.workspace}-bastion-host-sg-${random_id.name.hex}"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH access to bastion host from IPv4"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-bastion-host-sg-${random_id.name.hex}"
  }
}

resource "aws_security_group" "rds_postgres_sg" {
  name        = "${var.project_name}-${terraform.workspace}-rds-sg-${random_id.name.hex}"
  description = "Allow postgreSQL inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "PostgreSQL access to RDS from my bastion host"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host_sg.id]
  }

  ingress {
    description     = "PostgreSQL access to RDS from my EKS cluster"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-rds-sg-${random_id.name.hex}"
  }
}

resource "aws_security_group" "eks_bastion_host_sg" {
  name        = "${var.project_name}-${terraform.workspace}-eks-bastion-host-sg-${random_id.name.hex}"
  description = "Allow access to eks api from bastion host"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "HTTPS access to EKS API from my bastion host"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "${var.project_name}-${terraform.workspace}-eks-bastion-host-sg-${random_id.name.hex}"
  }
}

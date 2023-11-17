resource "aws_subnet" "subnet1_db" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "rds_subnet"
  }
}

resource "aws_subnet" "subnet2_db" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "rds_subnet"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_security_group"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      # mudar para o da aplicacao
      aws_subnet.subnet1_db.cidr_block,
      aws_subnet.subnet2_db.cidr_block,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "db_subnet_group"
  subnet_ids = [
    aws_subnet.subnet1_db.id,
    aws_subnet.subnet2_db.id,
  ]
}

resource "aws_db_instance" "db" {
  allocated_storage    = 5
  engine               = "postgres"
  engine_version       = "15.3"
  instance_class       = "db.t3.micro"
  db_name              = "groceries_db"
  username             = "postgres"
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot  = true

  backup_retention_period = 7
  backup_window           = "02:00-02:30"
  maintenance_window      = "Mon:03:00-Mon:04:00"
  multi_az                = true

  vpc_security_group_ids = [
    aws_security_group.db_sg.id,
  ]
}

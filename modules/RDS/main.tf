resource "aws_subnet" "subnet1_db" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "rds_subnet"
  }
}

resource "aws_subnet" "subnet2_db" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "rds_subnet"
  }
}

resource "aws_route_table" "route_table_db" {
  vpc_id = var.vpc_id

  #route {
  #  cidr_block     = "0.0.0.0/0"
  #  nat_gateway_id = var.nat_gateway_id
  #}

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "private_subnet1_db" {
  subnet_id      = aws_subnet.subnet1_db.id
  route_table_id = aws_route_table.route_table_db.id
}

resource "aws_route_table_association" "private_subnet2_db" {
  subnet_id      = aws_subnet.subnet2_db.id
  route_table_id = aws_route_table.route_table_db.id
}

resource "aws_security_group" "db_sg" {
  name        = "db_security_group"
  description = "RDS security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  password             = "12qwaszx"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot  = true

  backup_retention_period = 7
  backup_window           = "02:00-02:30"
  maintenance_window      = "Mon:03:00-Mon:04:00"
  # multi_az                = true

  vpc_security_group_ids = [
    aws_security_group.db_sg.id,
  ]
}

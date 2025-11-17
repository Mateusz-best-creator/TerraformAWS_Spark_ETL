
resource "aws_security_group" "allow_my_ip" {
  vpc_id = var.default_vpc_id

  ingress {
    from_port   = var.mysql_port
    to_port     = var.mysql_port
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_instance" "company_db" {
  allocated_storage   = 5
  identifier          = "companydatabase"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  username            = var.company_db_username
  password            = var.company_db_password
  skip_final_snapshot = true // required to destroy

  vpc_security_group_ids = [aws_security_group.allow_my_ip.id]
  publicly_accessible    = true
}


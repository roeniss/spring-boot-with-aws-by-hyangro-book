resource "aws_key_pair" "hyangro_key" {
  key_name   = "hyangro_key"
  public_key = file("./key.pub")
}

resource "aws_security_group" "outbound_all" {
  name        = "outbound-all"
  description = "outbound-all"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "spring" {
  name        = "spring"
  description = "spring"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "http" {
  name        = "http"
  description = "http"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "https" {
  name        = "https"
  description = "https"
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "ssh"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh_sg_to_db" {
  name        = "ssg-sg-to-db"
  description = "ssg-sg-to-db"
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [
      aws_security_group.ssh.id
    ]
  }
}

resource "aws_security_group" "all" {
  name        = "all"
  description = "all"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_eip" "web_ip" {
  instance = aws_instance.web_server.id
  vpc      = true
  tags = {
    Name = "향로 튜토리얼용"
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-023e14086fe5700ef"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.hyangro_key.key_name
  vpc_security_group_ids = [
    aws_security_group.spring.id,
    aws_security_group.outbound_all.id,
    aws_security_group.https.id,
    aws_security_group.http.id,
    aws_security_group.ssh.id,
  ]
  tags = {
    Name = "향로 튜토리얼용"
  }
  root_block_device {
    volume_size = 30
  }
}

resource "aws_db_parameter_group" "web_db" {
  name   = "utf-param-group"
  family = "mariadb10.2"
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_connection"
    value = "utf8mb4_general_ci"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_general_ci"
  }
  parameter {
    name  = "max_connections"
    value = 150
  }
  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }
}

resource "aws_db_instance" "web_db" {
  identifier              = "hyangro"
  allocated_storage       = 20
  engine                  = "mariadb"
  engine_version          = "10.2"
  instance_class          = "db.t2.micro"
  name                    = "hyangro"
  backup_retention_period = 7
  backup_window           = "02:00-03:00"
  maintenance_window      = "wed:03:00-wed:04:00"
  username                = var.db_username
  password                = var.db_password
  parameter_group_name    = aws_db_parameter_group.web_db.name
  skip_final_snapshot     = true
  vpc_security_group_ids = [
    aws_security_group.ssh_sg_to_db.id,
    aws_security_group.all.id # TODO: remove
  ]
}

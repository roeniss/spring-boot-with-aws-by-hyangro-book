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
    protocol    = "all"
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
    Name = "향로"
  }
  root_block_device {
    volume_size = 30
  }
  iam_instance_profile = aws_iam_instance_profile.web_server_profile.name
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
  publicly_accessible     = true
  vpc_security_group_ids = [
    aws_security_group.ssh_sg_to_db.id,
    aws_security_group.all.id # TODO: remove
  ]
}

resource "aws_iam_user" "cicd" {
  name = "cicd"
}

resource "aws_iam_user_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
  ])

  user       = aws_iam_user.cicd.name
  policy_arn = each.value
}

resource "aws_s3_bucket" "cicd_jar_bucket" {
  bucket = "cicd-jar-bucket"
  acl    = "private"

  tags = {
    Name = "hyangro cicd jar bucket"
  }
}

resource "aws_iam_instance_profile" "web_server_profile" {
  name = "test_profile"
  role = aws_iam_role.web_server.name
}

resource "aws_iam_role" "web_server" {
  name = "web-server-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


data "aws_iam_policy" "AmazonEC2RoleforAWSCodeDeploy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "web_server_attach" {
  role       = aws_iam_role.web_server.name
  policy_arn = data.aws_iam_policy.AmazonEC2RoleforAWSCodeDeploy.arn
}

resource "aws_codedeploy_app" "web_deploy" {
  compute_platform = "Server"
  name             = "hyangro-web-deploy"
}
resource "aws_iam_role" "web_deploy" {
  name = "web-deploy-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.web_deploy.name
}

resource "aws_codedeploy_deployment_group" "web_deploy" {
  app_name              = aws_codedeploy_app.web_deploy.name
  deployment_group_name = "web-deploy-group"
  service_role_arn      = aws_iam_role.web_deploy.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "향로"
    }
  }
}

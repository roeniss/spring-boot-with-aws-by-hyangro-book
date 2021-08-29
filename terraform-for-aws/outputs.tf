output "ec2_ip" {
  value = aws_eip.web_ip.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.web_db.endpoint
}

output "db_password" {
  value     = aws_db_instance.web_db.password
  sensitive = true
}

output "db_username" {
  value     = aws_db_instance.web_db.username
  sensitive = true
}

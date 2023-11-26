output "db_password" {
  value = aws_db_instance.db.password
}

output "db_host" {
  value = aws_db_instance.db.address
}

output "db_port" {
  value = aws_db_instance.db.port
}

output "db_name" {
  value = aws_db_instance.db.username
}

output "db_user" {
  value = aws_db_instance.db.username
}

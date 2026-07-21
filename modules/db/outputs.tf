output "db_endpoint" {
  value = aws_db_instance.wp_db.endpoint
  sensitive = true
}

output "db_password" {
  value = aws_db_instance.wp_db.password
  sensitive = true
}

output "db_name" {
  value = aws_db_instance.wp_db.db_name
}

output "db_user" {
  value = aws_db_instance.wp_db.username
  sensitive = true
}


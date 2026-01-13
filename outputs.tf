# Outputs
output "ec2_public_ip" {
  value = aws_instance.wordpress_ec2.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.wordpress_db.endpoint
}

output "ssh_command" {
  value = "ssh -i ${local_file.ssh_key.filename} ec2-user@${aws_instance.wordpress_ec2.public_ip}"
}
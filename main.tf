provider "aws" {
  region = "us-east-1"
}

# Generate SSH Key Pair locally
resource "tls_private_key" "wp_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "wordpress_key" {
  key_name   = "wordpress-key"
  public_key = tls_private_key.wp_key.public_key_openssh
}

# Save the private key to your local machine and set permissions
resource "local_file" "ssh_key" {
  filename        = "${path.module}/wordpress-key.pem"
  content         = tls_private_key.wp_key.private_key_pem
  file_permission = "0400"
}


# RDS Instance
resource "aws_db_subnet_group" "db_subnets" {
  name       = "wordpress-db-subnets"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "wordpress_db" {
  identifier             = "wordpress"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 0
  db_name                = "webserver"
  username               = "admin"
  password               = "password123"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
  availability_zone      = "us-east-1a"
}

# EC2 Instance
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "wordpress_ec2" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = aws_key_pair.wordpress_key.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

user_data = templatefile("${path.module}/userdata.tftpl", {
    db_endpoint = aws_db_instance.wordpress_db.address
    db_password = aws_db_instance.wordpress_db.password
  })

  tags = {
    Name = "wordpress"
  }
}


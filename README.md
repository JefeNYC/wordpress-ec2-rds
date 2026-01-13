# wordpress-ec2-rds
A lightweight Terraform template to deploy WordPress on Amazon Linux 2023 with automated RDS integration, custom VPC networking, and dynamic bootstrapping.

AWS WordPress Lab: Fully Automated IaC Deployment
This repository features a Terraform configuration to deploy a fully functional WordPress site on AWS. Unlike a standard manual install, this project utilizes Dynamic Bootstrapping to automatically connect the compute and database layers without any manual configuration required in the WordPress UI.

🏗️ Architecture
The infrastructure is built using a modular and automated approach:

Networking: A custom VPC (via the terraform-aws-modules VPC module) with public subnets for the web server and private subnets for the RDS database.

Compute: A t3.micro instance running Amazon Linux 2023.

Database: Amazon RDS (MySQL 8.0) isolated from the public internet, accessible only by the EC2 instance.

Security: * Security Groups act as virtual firewalls (Port 80 for Web, Port 22 for SSH).

Automated local generation of a .pem SSH key for secure access.

🚀 Key Improvements
Dynamic Templating: Uses Terraform’s templatefile() to inject the RDS Endpoint and Database Credentials directly into the wp-config.php during the EC2 launch.

Zero-Touch Installation: Once terraform apply finishes, the site is ready for the "Famous 5-Minute Install" immediately—no database connection errors.

Automated AMI Tracking: Always uses the latest Amazon Linux 2023 AMI via the AWS SSM Parameter Store.

🛠️ Usage
Initialize & Deploy:

Bash

terraform init
terraform apply 
Access Your Site: Copy the ec2_public_ip from the output and paste it into your browser.

SSH for Debugging: Use the ssh_command output to log into the instance using the automatically generated key:

Bash

ssh -i wordpress-key.pem ec2-user@<public-ip>
🧹 Cleanup
To destroy all resources and avoid unexpected AWS costs:

Bash

terraform destroy --auto-approve
resource "aws_instance" "app_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user

              # Autenticarse con ECR
              $(aws ecr get-login --no-include-email --region ${var.region})

              # Descargar y ejecutar la imagen de ECR
              docker pull ${var.ecr_repository_uri}:latest
              docker run -d -p 8080:8080 --name devops ${var.ecr_repository_uri}:latest
              EOF

  tags = {
    Name = "EC2-Docker-App"
  }
}
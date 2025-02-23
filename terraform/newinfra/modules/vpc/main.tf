provider "aws" {
    region = var.region
}

resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        Name = "main-vpc"
    }
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = var.zone_a
    map_public_ip_on_launch = true
    
    tags = {
        Name = "public-subnet1"
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id            = aws_vpc.main_vpc.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = var.zone_b
    map_public_ip_on_launch = true
    
    tags = {
        Name = "public-subnet2"
    }
}

resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main_vpc.id
    tags = {
        Name = "main_igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_igw.id
    }

    tags = {
        Name = "public_route_table"
    }
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

#Security group
resource "aws_security_group" "alb_sg" {
  name = "alb-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "server-sg"
  }
}

resource "aws_alb" "app_alb" {
  name               = "project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  # Uso del Classic Load Balancer
  enable_deletion_protection = false
  idle_timeout             = 60
}

resource "aws_alb_target_group" "tg" {
  name     = "project-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.tg.arn
  }
}

resource "aws_launch_template" "app_server_1" {
  image_id      = var.ami_base
  instance_type = var.instance_type
  update_default_version = true
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.alb_sg.id]
    subnet_id                   = aws_subnet.public_subnet_1.id
  }
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
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "DevOps-App-Instance"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "asg" {
  desired_capacity     = var.desired_capacity
  max_size             = var.max_size
  min_size             = var.min_size
  vpc_zone_identifier  = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  launch_template {
    id      = aws_launch_template.app_server_1.id
    version = "$Latest"
  }

 # Política de actualización para reemplazar instancias existentes
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
  
  tag {
    key                 = "Name"
    value               = "ec2-instance-asg"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}
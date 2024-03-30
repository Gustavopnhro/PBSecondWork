terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_subnet" "subnet-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "subnet-b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
}

resource "aws_route_table_association" "route_table_association-subnet-b" {
  subnet_id = aws_subnet.subnet-a.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "route_table_association-subnet-a" {
  subnet_id = aws_subnet.subnet-b.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "lb-security-group" {
  name        = "lb-sg-001"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "efs-security-group" {
  name        = "efs-sg-002"
  description = "Allow NFS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2-security-group.id]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [aws_security_group.lb-security-group.id]
  }

  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "rds-security-group" {
  name        = "rds-sg-002"
  description = "Allow MySQL inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2-security-group" {
  name        = "ec2-sg-002"
  description = "Allow Load Balancer inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.lb-security-group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_efs_file_system" "efs" {
  creation_token = "wordpress-002"
  encrypted = true
}

resource "aws_efs_mount_target" "efs-mount-a" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.subnet-a.id
  security_groups = [aws_security_group.efs-security-group.id]
}

resource "aws_efs_mount_target" "efs-mount-b" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.subnet-b.id
  security_groups = [aws_security_group.efs-security-group.id]
}

resource "aws_elb" "classic-load-balancer" {
  name               = "classic-load-balancer"
  subnets = [aws_subnet.subnet-a.id, aws_subnet.subnet-b.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  security_groups = [aws_security_group.lb-security-group.id]
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/wp-admin/install.php"
    interval            = 30
  }

}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "my-db-subnet-group"
  subnet_ids = [aws_subnet.subnet-a.id, aws_subnet.subnet-b.id]
}

resource "aws_key_pair" "key_pair" {
  key_name   = "keyPair001"
  public_key = file("~/.ssh/id_rsa.pub")
}


resource "aws_db_instance" "wordpress-db" {
  allocated_storage = 10
  engine = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t3.micro"
  db_name = "wordpress"
  username = "admin"
  password = "wordpassword"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.rds-security-group.id]
}


resource "aws_launch_template" "launch-template" {
  image_id      = "ami-0c101f26f147fa7fd" 
  instance_type = "t3.small"
  #vpc_security_group_ids = [aws_security_group.ec2-security-group.id]
  key_name = aws_key_pair.key_pair.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.ec2-security-group.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = ""
      "CostCenter" = ""
      "Project"    = ""
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      "Name" = ""
      "CostCenter" = ""
      "Project"    = ""
    }
  }
  

  user_data = base64encode(<<-EOF
              #!/bin/bash

              sudo yum update -y
              sudo yum install docker -y && sudo yum install amazon-efs-utils -y
              sudo usermod -aG docker $(whoami)
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo mkdir /mnt/efs
              sudo yum install stress -y
              sudo echo "${aws_efs_file_system.efs.dns_name}:/    /mnt/efs    nfs4    defaults,_netdev,rw    0   0" >>  /etc/fstab 
              sudo mount -a
              sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /bin/docker-compose
              sudo chmod +x /bin/docker-compose
              cat <<EOL > /home/ec2-user/docker-compose.yml
              version: '3.8'
              services:
                wordpress:  
                  image: wordpress:latest
                  volumes:
                    - /mnt/efs/wordpress:/var/www/html
                  ports:
                    - 80:80
                  environment:
                    WORDPRESS_DB_HOST: ${aws_db_instance.wordpress-db.endpoint}
                    WORDPRESS_DB_USER: admin
                    WORDPRESS_DB_PASSWORD: wordpassword
                    WORDPRESS_DB_NAME: wordpress
                    WORDPRESS_TABLE_CONFIG: wp_
              EOL
              sudo docker-compose -f /home/ec2-user/docker-compose.yml up -d
              sudo yum update
              EOF
            )
}


resource "aws_cloudwatch_metric_alarm" "cpu_alarm_high" {
  alarm_name          = "cpu_alarm_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale up when CPU usage exceeds 30%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.autoscaling.name
  }

  alarm_actions = [aws_autoscaling_policy.policy-upgrade.arn]
}

resource "aws_autoscaling_group" "autoscaling" {
  name = "asg-wordpress"
  vpc_zone_identifier  = [aws_subnet.subnet-a.id, aws_subnet.subnet-b.id]
  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  load_balancers   = [aws_elb.classic-load-balancer.name]

  launch_template {
    id      = aws_launch_template.launch-template.id
    version = "$Latest"
  }

}

resource "aws_autoscaling_policy" "policy-upgrade" {
  name                   = "target-group-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.autoscaling.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 30
  }
}
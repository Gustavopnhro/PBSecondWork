#!/bin/bash

sudo yum update -y
sudo yum install docker -y && sudo yum install amazon-efs-utils -y
sudo usermod -aG docker $(whoami)
sudo systemctl start docker
sudo systemctl enable docker
sudo mkdir /mnt/efs
sudo su
sudo echo "fs-0d4ccf2167f49f408.efs.us-east-1.amazonaws.com:/    /mnt/efs    nfs4    defaults,_netdev,rw    0   0" >  /etc/fstab 
mount -a
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
      WORDPRESS_DB_HOST: database-0.c5oe8kc447xs.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: wordpassword
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_TABLE_CONFIG: wp_
EOL
sudo docker-compose -f /home/ec2-user/docker-compose.yml up -d
sudo yum update

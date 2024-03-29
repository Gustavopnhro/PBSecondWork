#!/bin/bash

sudo yum update -y
sudo yum install docker -y && sudo yum install amazon-efs-utils -y
sudo usermod -aG docker $(whoami)
sudo systemctl start docker
sudo systemctl enable docker
sudo mkdir /mnt/efs
sudo su
echo "<efs_dns>:/    /mnt/efs    nfs4    defaults,_netdev,rw    0   0" >  /etc/fstab 
mount -a
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /bin/docker-compose
chmod +x /bin/docker-compose
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
      WORDPRESS_DB_HOST: <RDS endpoint>
      WORDPRESS_DB_USER: <master user>
      WORDPRESS_DB_PASSWORD: <master password>
      WORDPRESS_DB_NAME: <initial database>
      WORDPRESS_TABLE_CONFIG: wp_
EOL
docker-compose -f /home/ec2-user/docker-compose.yml up -d
yum update

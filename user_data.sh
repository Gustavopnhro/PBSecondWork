#!/bin/bash

sudo yum update -y
sudo yum install docker -y && sudo yum install amazon-efs-utils -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)
sudo mkdir /mnt/efs
sudo su
echo "fs-0d4ccf2167f49f408.efs.us-east-1.amazonaws.com:/    /mnt/efs    nfs4    defaults,_netdev,rw    0   0" >  /etc/fstab 
mount -a
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo mv /usr/local/bin/docker-compose /bin/docker-compose
sudo docker-compose -f /mnt/efs/docker-compose.yml up -d
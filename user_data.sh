#!/bin/bash

sudo yum update -y
sudo yum docker install -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $(whoami)
sudo reboot
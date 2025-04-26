#!/bin/bash
# Update the instance
sudo apt update -y
sudo apt upgrade -y

# Install AWS CLI
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Ensure SSM Agent is installed and started (Optional for Ubuntu 22+)
sudo snap install amazon-ssm-agent --classic || true
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

# Clean up
rm -rf awscliv2.zip aws/

echo "Bootstrapping completed successfully!"

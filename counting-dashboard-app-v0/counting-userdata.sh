#!/bin/bash

sudo apt update -y
sudo apt-get install net-tools zip curl jq tree unzip wget siege apt-transport-https ca-certificates software-properties-common gnupg lsb-release -y
sudo curl -L https://github.com/hashicorp/demo-consul-101/releases/download/v0.0.5/counting-service_linux_amd64.zip -o counting-service.zip
sleep 3
sudo unzip counting-service.zip
sudo rm -rf counting-service.zip
sudo mv counting-service_linux_amd64 counting-service
sudo mv counting-service /usr/bin/counting-service
sudo chmod 755 /usr/bin/counting-service
sudo chown ubuntu:ubuntu /usr/bin/counting-service


sudo cat > /etc/systemd/system/counting-api.service << 'EOF'

[Unit]
Description=counting API service
After=syslog.target network.target
 
[Service]
ExecStart=/usr/bin/counting-service
Environment=PORT="9009"
User=ubuntu
Group=ubuntu
ExecStop=/bin/sleep 5
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sleep 1
sudo systemctl enable counting-api.service
sudo systemctl start counting-api.service
sleep 2
sudo systemctl status counting-api.service
sudo lsof -i -P | grep counting
#!/bin/bash

sudo apt update -y
sudo apt-get install net-tools zip curl jq tree unzip wget siege apt-transport-https ca-certificates software-properties-common gnupg lsb-release -y
sudo curl -L https://github.com/hashicorp/demo-consul-101/releases/download/v0.0.5/dashboard-service_linux_amd64.zip -o dashboard-service.zip
sudo unzip dashboard-service.zip
sudo rm -rf dashboard-service.zip
sudo mv dashboard-service_linux_amd64 dashboard-service
sudo mv dashboard-service /usr/bin/dashboard-service
sudo chmod 755 /usr/bin/dashboard-service
sudo chown ubuntu:ubuntu /usr/bin/dashboard-service


sudo cat > /etc/systemd/system/dashboard-api.service << EOF

[Unit]
Description=Dashboard API service
After=syslog.target network.target
 
[Service]
Environment=PORT="9009"
Environment=COUNTING_SERVICE_URL="http://${counting_ip}:9009"
ExecStart=/usr/bin/dashboard-service
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
sudo systemctl enable dashboard-api.service
sudo systemctl start dashboard-api.service
sleep 3
sudo systemctl status dashboard-api.service
sudo lsof -i -P | grep dashboard
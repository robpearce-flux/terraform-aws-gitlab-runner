#!/bin/bash -e

# Setup proxy in various places
echo "http_proxy=\"http://${http_proxy}\"
https_proxy=\"http://${https_proxy}\"
no_proxy=\"169.254.169.254,10.0.0.0/8\"" >> /etc/environment

echo "Acquire::http::Proxy \"http://${http_proxy}/\";
Acquire::https::Proxy \"http://${https_proxy}/\";" >> /etc/apt/apt.conf.d/proxy.conf

# Setup the docker service
mkdir -p /etc/systemd/system/docker.service.d/
echo "[Service]
Environment=\"http_proxy=http://${http_proxy}\"
Environment=\"https_proxy=http://${https_proxy}\"
Environment=\"no_proxy=169.254.169.254,10.0.0.0/8\"" > /etc/systemd/system/docker.service.d/http-proxy.conf

# Setup ecr credentials helper
apt install -y amazon-ecr-credential-helper
mkdir -p /root/.docker/
echo '{ "credsStore": "ecr-login" }' > /root/.docker/config.json
#!/bin/bash -e
echo "http_proxy=\"http://${http_proxy}\"" >> /etc/environment
echo "https_proxy=\"http://${https_proxy}\"" >> /etc/environment
echo "no_proxy=\"169.254.169.254,10.0.0.0/8\"" >> /etc/environment

echo "Acquire::http::Proxy \"http://${http_proxy}/\";" >> /etc/apt/apt.conf.d/proxy.conf
echo "Acquire::https::Proxy \"http://${https_proxy}/\";" >> /etc/apt/apt.conf.d/proxy.conf

mkdir -p /etc/systemd/system/docker.service.d/
echo "[Service]
Environment=\"http_proxy=http://${http_proxy}\"
Environment=\"https_proxy=http://${https_proxy}\"
Environment=\"no_proxy=169.254.169.254,10.0.0.0/8\"" > /etc/systemd/system/docker.service.d/http-proxy.conf

apt install -y amazon-ecr-credential-helper
echo '{ "credsStore": "ecr-login" }' > ~/.docker/config.json
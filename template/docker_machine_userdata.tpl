#!/bin/bash -e
echo "http_proxy=\"http://${http_proxy}\"" >> /etc/environment
echo "https_proxy=\"http://${https_proxy}\"" >> /etc/environment

echo "Acquire::http::Proxy \"http://${http_proxy}/\";" >> /etc/apt/apt.conf.d/proxy.conf
echo "Acquire::https::Proxy \"http://${https_proxy}/\";" >> /etc/apt/apt.conf.d/proxy.conf

mkdir -p /etc/systemd/system/docker.service.d/
echo "[Service]
Environment=\"http_proxy=http://${http_proxy}\"
Environment=\"https_proxy=http://${https_proxy}\"
Environment=\"no_proxy=169.254.169.254\"" > /etc/systemd/system/docker.service.d/http-proxy.conf

git clone --depth 1 https://github.com/awslabs/amazon-ecr-credential-helper.git
cd amazon-ecr-credential-helper && make docker
mv ~/amazon-ecr-credential-helper/bin/local/docker-credential-ecr-login /usr/local/bin/docker-credential-ecr-login
mkdir -p ~/.docker
echo > ~/.docker/config.json '{ "credsStore": "ecr-login" }'

#!/bin/bash -e

export http_proxy=${http_proxy}
export HTTP_PROXY=${http_proxy}
export https_proxy=${https_proxy}
export HTTPS_PROXY=${https_proxy}
export no_proxy=169.254.169.254,10.0.0.0/8
export NO_PROXY=169.254.169.254,10.0.0.0/8

# Setup proxy in various places
echo "http_proxy=\"http://${http_proxy}\"" >> /etc/environment
echo "https_proxy=\"http://${https_proxy}\"" >> /etc/environment
echo "no_proxy=\"169.254.169.254,10.0.0.0/8\"" >> /etc/environment

echo "Acquire::http::Proxy \"http://${http_proxy}/\";" >> /etc/apt/apt.conf.d/proxy.conf
echo "Acquire::https::Proxy \"http://${https_proxy}/\";" >> /etc/apt/apt.conf.d/proxy.conf

# Setup the docker service
mkdir -p /etc/systemd/system/docker.service.d/
echo "[Service]
Environment=\"http_proxy=http://${http_proxy}\"
Environment=\"https_proxy=http://${https_proxy}\"
Environment=\"no_proxy=169.254.169.254,10.0.0.0/8\"" > /etc/systemd/system/docker.service.d/http-proxy.conf

# Setup ecr credentials helper
mkdir -p /root/.docker/
echo '{ "credsStore": "ecr-login" }' > /root/.docker/config.json

max_retry=60
for i in `seq $max_retry`;
do
  apt install amazon-ecr-credential-helper && break || sleep 1
  echo "Sleep [$i] of $[max_retry]"
done

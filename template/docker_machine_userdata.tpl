#!/bin/bash -e
export http_proxy="http://${http_proxy}"
export https_proxy="http://${https_proxy}"
export no_proxy=169.254.169.254
export HTTP_PROXY="http://${http_proxy}"
export HTTPS_PROXY="http://${https_proxy}"
export NO_PROXY=169.254.169.254

echo "http_proxy=\"http://${http_proxy}\"" >> /etc/environment
echo "https_proxy=\"https://${https_proxy}\"" >> /etc/environment

echo "Acquire::http::Proxy \"http://${http_proxy}/\";" >> /etc/apt/apt.conf.d/proxy.conf
echo "Acquire::https::Proxy \"https://${https_proxy}/\";" >> /etc/apt/apt.conf.d/proxy.conf

mkdir -p /etc/systemd/system/docker.service.d/
echo "[Service]
Environment=\"http_proxy=http://${http_proxy}\"
Environment=\"https_proxy=http://${https_proxy}\"
Environment=\"no_proxy=169.254.169.254\"" > /etc/systemd/system/docker.service.d/http-proxy.conf
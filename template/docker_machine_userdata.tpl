#cloud-boothook
#!/bin/bash -e
mkdir /etc/docker
export http_proxy=http://${http_proxy}
export HTTP_PROXY=http://${http_proxy}
export https_proxy=http://${https_proxy}
export HTTPS_PROXY=http://${https_proxy}
export no_proxy=${no_proxy}
export NO_PROXY=${no_proxy}

# Setup proxy in various places
echo "http_proxy=\"http://${http_proxy}\"" >> /etc/environment
echo "https_proxy=\"http://${https_proxy}\"" >> /etc/environment
echo "no_proxy=\"${no_proxy}\"" >> /etc/environment

# Setup the docker service
mkdir -p /etc/systemd/system/docker.service.d/
echo "[Service]
Environment=\"http_proxy=http://${http_proxy}\"
Environment=\"https_proxy=http://${https_proxy}\"
Environment=\"no_proxy=${no_proxy}\"" > /etc/systemd/system/docker.service.d/http-proxy.conf

systemctl daemon-reload
systemctl restart docker || true # May not have been installed yet via ssh (timing issue)

echo "Acquire::http::Proxy \"http://${http_proxy}/\";" >> /etc/apt/apt.conf.d/proxy.conf
echo "Acquire::https::Proxy \"http://${https_proxy}/\";" >> /etc/apt/apt.conf.d/proxy.conf

echo "${git_server_private_ip} ${git_server_domain}" >> /etc/hosts

apt install amazon-ecr-credential-helper
# Setup ecr credentials helper
mkdir -p /root/.docker/
echo '{ "credsStore": "ecr-login" }' > /root/.docker/config.json

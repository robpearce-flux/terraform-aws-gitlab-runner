#!/bin/bash -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Set proxy for gitlab runner service, when it gets installed later on...
mkdir /etc/systemd/system/gitlab-runner.service.d
echo "[Service]
Environment=\"http_proxy=${http_proxy}\"
Environment=\"https_proxy=${http_proxy}\"
Environment=\"no_proxy=169.254.169.254,10.0.0.0/8\"" > /etc/systemd/system/gitlab-runner.service.d/http-proxy.conf

# Set proxy for yum
echo "proxy=http://${http_proxy}" >> /etc/yum.conf

# Some tools later in this user-data script want uppercase and some lower, so lets just do both.
export http_proxy=${http_proxy}
export HTTP_PROXY=${http_proxy}
export https_proxy=${https_proxy}
export HTTPS_PROXY=${https_proxy}
export no_proxy=169.254.169.254,10.0.0.0/8
export NO_PROXY=169.254.169.254,10.0.0.0/8

# Install the ecr credentials helper
git clone --depth 1 https://github.com/IrmantasM/amazon-ecr-credential-helper.git
cd amazon-ecr-credential-helper && make docker
mv ~/amazon-ecr-credential-helper/bin/local/docker-credential-ecr-login /usr/local/bin/docker-credential-ecr-login
mkdir -p ~/.docker
echo > ~/.docker/config.json '{ "credsStore": "ecr-login" }'

echo "${machine_userdata_b64}" | base64 -d > ${machine_userdata_filepath}

if [[ $(echo ${user_data_trace_log}) == false ]]; then
  set -x
fi

# Add current hostname to hosts file
tee /etc/hosts <<EOL
127.0.0.1   localhost localhost.localdomain $(hostname)
EOL

${eip}

for i in {1..7}; do
  echo "Attempt: ---- " $i
  yum -y update && break || sleep 60
done

${logging}

${gitlab_runner}

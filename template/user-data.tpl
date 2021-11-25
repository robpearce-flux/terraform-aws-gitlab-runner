#!/bin/bash -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "http_proxy=${http_proxy}
HTTP_PROXY=${http_proxy}

https_proxy=${https_proxy}
HTTPS_PROXY=${http_proxy}

no_proxy=169.254.169.254
NO_PROXY=169.254.169.254" >> /etc/profile

export http_proxy=${http_proxy}
export HTTP_PROXY=${http_proxy}
# For aws cli tools which use golang - uppercase
export https_proxy=${https_proxy}
export HTTPS_PROXY=${https_proxy}

export no_proxy=169.254.169.254
export NO_PROXY=169.254.169.254

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

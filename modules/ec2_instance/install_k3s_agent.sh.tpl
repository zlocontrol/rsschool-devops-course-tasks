#!/bin/bash
set -ex

echo "--- START: K3s Agent user-data ---"
date

# 1. Minimal network check
ping -c 1 8.8.8.8 || exit 1
curl -sS -o /dev/null --connect-timeout 10 https://www.google.com || exit 1

# 2. Swap
if ! swapon --summary | grep -q "/swapfile"; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# 3. Disable Rancher repository and update the system
yum-config-manager --disable rancher* || true
rm -f /etc/yum.repos.d/rancher*.repo || true

yum clean all -y
yum update -y || true
yum install -y curl awscli || true

# 4. Get K3s token from SSM
K3S_TOKEN=""
TIMEOUT_SSM_TOKEN_SECONDS=${TIMEOUT_SSM_TOKEN_SECONDS}
START_TIME=$(date +%s)

until [ -n "$K3S_TOKEN" ]; do
  NOW=$(date +%s)
  ELAPSED=$((NOW - START_TIME))
  if [ "$ELAPSED" -ge "$TIMEOUT_SSM_TOKEN_SECONDS" ]; then
    echo "ERROR: SSM token не получен за $TIMEOUT_SSM_TOKEN_SECONDS сек."
    exit 1
  fi
  K3S_TOKEN=$(aws ssm get-parameter --name "${k3s_token_ssm_path}" --with-decryption --region ${aws_region} --query "Parameter.Value" --output text 2>/dev/null)
  [ -z "$K3S_TOKEN" ] && sleep 5
done
echo "Token received."

# 5. Installing an agent without SELinux
export K3S_URL="https://${master_private_ip}:6443"
export K3S_TOKEN="$K3S_TOKEN"

curl -sfL https://get.k3s.io | INSTALL_K3S_SELINUX_DISABLE=true INSTALL_K3S_SKIP_SELINUX_RPM=true sh -
echo "Agent installed."

# 6. kubectl symlink
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl

# 7. Update .bashrc for ec2-user
cat <<EOF >> /home/ec2-user/.bashrc

# K3s agent kubectl setup
export PATH=\$PATH:/usr/local/bin:/usr/bin
alias k="kubectl"
EOF

echo "--- DONE: K3s Agent user-data ---"
date

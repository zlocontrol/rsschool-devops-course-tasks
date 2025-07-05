#!/bin/bash
set -ex

echo "--- START: K3s Master user-data ---"
date

# 1. Let's check the network
echo "Checking internet connectivity..."
for i in {1..5}; do
  if ping -c 1 8.8.8.8; then
    echo "Internet OK"
    break
  fi
  echo "No internet yet, waiting 5s..."
  sleep 5
done

if ! ping -c 1 8.8.8.8; then
  echo "WARNING: No internet after retries, continuing anyway"
fi


# 2. Swap
if ! swapon --summary | grep -q "/swapfile"; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# 3. Disable rancher repository and update the system
yum-config-manager --disable rancher* || true
rm -f /etc/yum.repos.d/rancher*.repo || true

yum clean all -y
yum update -y || true

# ===Insert the token===
export K3S_TOKEN="${k3s_token}"

#3.1. Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp
sudo /tmp/aws/install --update


# 4. Install K3s Master WITH SELinux RPM COMPLETELY DISABLED
curl -sfL https://get.k3s.io | INSTALL_K3S_SELINUX_DISABLE=true INSTALL_K3S_SKIP_SELINUX_RPM=true sh -

# 5. Make sure there is a kubectl symlink
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl

# 6. Copy kubeconfig WITH PRIVATE_IP PATCH
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
mkdir -p /home/ec2-user/.kube
sed "s/127.0.0.1/$PRIVATE_IP/" /etc/rancher/k3s/k3s.yaml > /home/ec2-user/.kube/config
chown -R ec2-user:ec2-user /home/ec2-user/.kube

# 7. Write to .bashrc
echo "
export KUBECONFIG=/home/ec2-user/.kube/config
export PATH=\$PATH:/usr/local/bin
alias k='kubectl'
" >> /home/ec2-user/.bashrc

# 8. Upload kubeconfig to SSM
echo "Uploading kubeconfig to SSM: /my-project-dev/kubeconfig"
aws ssm put-parameter \
  --name "/my-project-dev/kubeconfig" \
  --type SecureString \
  --value "$(sudo cat /home/ec2-user/.kube/config)" \
  --overwrite \
  --region "${aws_region}"
echo "kubeconfig uploaded to SSM at /my-project-dev/kubeconfig"





echo "--- FINISH: K3s Master user-data ---"
date

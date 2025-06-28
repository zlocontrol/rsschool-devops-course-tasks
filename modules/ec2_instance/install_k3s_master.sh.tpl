#!/bin/bash
set -ex

echo "--- START: K3s Master user-data ---"
date

# 1. Проверим сеть
ping -c 1 8.8.8.8 || exit 1
curl -sS -o /dev/null --connect-timeout 10 https://www.google.com || exit 1

# 2. Swap (по желанию)
if ! swapon --summary | grep -q "/swapfile"; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# 3. Отключить rancher репозиторий и обновить систему
yum-config-manager --disable rancher* || true
rm -f /etc/yum.repos.d/rancher*.repo || true

yum clean all -y
yum update -y || true

# === 👉 Вот тут ВАЖНО: Вставляем правильный токен ===
export K3S_TOKEN="${k3s_token}"

# 4. Установить K3s Master, ПОЛНОСТЬЮ ОТКЛЮЧИВ SELinux RPM
curl -sfL https://get.k3s.io | INSTALL_K3S_SELINUX_DISABLE=true INSTALL_K3S_SKIP_SELINUX_RPM=true sh -

# 5. Убедиться, что есть симлинк kubectl
ln -sf /usr/local/bin/k3s /usr/local/bin/kubectl

# 6. Скопировать kubeconfig
mkdir -p /home/ec2-user/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
chown -R ec2-user:ec2-user /home/ec2-user/.kube

# 7. Записать в .bashrc
echo "
export KUBECONFIG=/home/ec2-user/.kube/config
export PATH=\$PATH:/usr/local/bin
alias k='kubectl'
" >> /home/ec2-user/.bashrc

echo "--- FINISH: K3s Master user-data ---"
date

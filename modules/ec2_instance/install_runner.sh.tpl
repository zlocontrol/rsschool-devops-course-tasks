#!/bin/bash
set -eux

echo "===> Updating packages"
sudo apt-get update -y
sudo apt-get install -y curl jq tar

echo "===> Preparing clean runner directory"
sudo rm -rf /opt/actions-runner
sudo mkdir -p /opt/actions-runner
sudo chown -R ubuntu:ubuntu /opt/actions-runner
cd /opt/actions-runner

RUNNER_VERSION="2.325.0"
RUNNER_ARCH="x64"

echo "===> Downloading GitHub Actions Runner version $RUNNER_VERSION"
curl -L -o actions-runner-linux-$RUNNER_ARCH-$RUNNER_VERSION.tar.gz \
  https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-$RUNNER_ARCH-$RUNNER_VERSION.tar.gz

echo "===> Extracting runner archive"
# Вот КЛЮЧЕВОЕ:
sudo tar --no-same-owner -xzf actions-runner-linux-$RUNNER_ARCH-$RUNNER_VERSION.tar.gz -C /opt/actions-runner

echo "===> Checking extracted files"
ls -la /opt/actions-runner

echo "===> Configuring runner"
sudo -u ubuntu /opt/actions-runner/config.sh \
  --url "${github_url}/${repo_name}" \
  --token "${runner_token}" \
  --unattended \
  --name "gha-selfhosted-runner"

echo "===> Installing runner as a service"
sudo /opt/actions-runner/svc.sh install

echo "===> Enabling and starting runner service"
sudo systemctl enable actions.runner.zlocontrol-rsschool-devops-course-tasks.gha-selfhosted-runner.service
sudo systemctl start actions.runner.zlocontrol-rsschool-devops-course-tasks.gha-selfhosted-runner.service
echo "===> GitHub Actions Runner setup complete!"

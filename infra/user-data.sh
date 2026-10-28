#!/bin/bash
set -euxo pipefail

dnf install -y docker git
systemctl enable --now docker
usermod -aG docker ec2-user

sudo -u ec2-user git clone ${repo_url} /home/ec2-user/demo-ec2
sudo -u ec2-user bash /home/ec2-user/demo-ec2/deploy/docker-up.sh

cat >/etc/motd <<'EOF'
Dome demo
Repo: /home/ec2-user/demo-ec2
App listens on port 8080.
Redeploy: bash ~/demo-ec2/deploy/docker-up.sh
EOF

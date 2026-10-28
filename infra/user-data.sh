#!/bin/bash
set -euxo pipefail

dnf install -y docker git
systemctl enable --now docker
usermod -aG docker ec2-user

cat >/etc/motd <<'EOF'
Dome demo
Docker and git are installed.
Clone the repo, then run:
  bash ~/demo-ec2/deploy/docker-up.sh
The app listens on port 8080.
EOF

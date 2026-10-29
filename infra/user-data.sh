#!/bin/bash
set -euxo pipefail

dnf install -y docker git
systemctl enable --now docker
usermod -aG docker ec2-user

set +x
cat > /home/ec2-user/db.env <<EOF
ConnectionStrings__Dome=Host=${db_host};Port=${db_port};Database=${db_name};Username=${db_user};Password=${db_password};SSL Mode=Require;Trust Server Certificate=true
EOF
set -x
chown ec2-user:ec2-user /home/ec2-user/db.env
chmod 600 /home/ec2-user/db.env

sudo -u ec2-user git clone ${repo_url} /home/ec2-user/demo-ec2
sudo -u ec2-user bash /home/ec2-user/demo-ec2/deploy/docker-up.sh

cat >/etc/motd <<'EOF'
Dome demo
Repo: /home/ec2-user/demo-ec2
App listens on port 8080.
Database env: /home/ec2-user/db.env
Redeploy: bash ~/demo-ec2/deploy/docker-up.sh
EOF

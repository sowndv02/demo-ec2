#!/bin/bash
set -euxo pipefail

dnf install -y docker git postgresql16
systemctl enable --now docker
usermod -aG docker ec2-user

set +x
cat > /home/ec2-user/db.env <<EOF
ConnectionStrings__Dome=Host=${db_host};Port=${db_port};Database=${db_name};Username=${db_user};Password=${db_password};SSL Mode=Require;Trust Server Certificate=true
EOF
cat > /home/ec2-user/.pgpass <<EOF
${db_host}:${db_port}:${db_name}:${db_user}:${db_password}
EOF
cat > /etc/profile.d/dome-db.sh <<EOF
export PGHOST=${db_host}
export PGPORT=${db_port}
export PGDATABASE=${db_name}
export PGUSER=${db_user}
export PGSSLMODE=require
EOF
set -x
chown ec2-user:ec2-user /home/ec2-user/db.env /home/ec2-user/.pgpass
chmod 600 /home/ec2-user/db.env /home/ec2-user/.pgpass

sudo -u ec2-user git clone ${repo_url} /home/ec2-user/demo-ec2
sudo -u ec2-user bash /home/ec2-user/demo-ec2/deploy/docker-up.sh

cat >/etc/motd <<'EOF'
Dome demo
Repo: /home/ec2-user/demo-ec2
App listens on port 8080.
Check the database:
  psql -c "SELECT inet_server_addr(), COUNT(*) FROM demo_ping;"
Redeploy: bash ~/demo-ec2/deploy/docker-up.sh
EOF

#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v git >/dev/null 2>&1; then
  sudo dnf install -y git
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Thu muc nay chua phai git repo. Clone truoc, roi chay lai script."
  exit 1
fi

git pull --ff-only

if ! swapon --show | grep -q '/swapfile'; then
  if [[ ! -f /swapfile ]]; then
    sudo dd if=/dev/zero of=/swapfile bs=1M count=1024 status=progress
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
  fi
  sudo swapon /swapfile
fi

sudo docker build -t dome "$ROOT"
sudo docker rm -f dome >/dev/null 2>&1 || true
sudo docker run -d --name dome --restart unless-stopped -p 8080:8080 dome
sudo docker ps --filter name=dome

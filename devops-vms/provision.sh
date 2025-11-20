#!/usr/bin/env bash
set -e

apt-get update
apt-get install -y docker.io
systemctl enable --now docker

# сеть
docker network create devops-net || true

# на всякий случай удалить старые контейнеры
docker rm -f backend devops-postgres || true

# postgres
docker run -d \
  --name devops-postgres \
  --network devops-net \
  -e POSTGRES_DB=appdb \
  -e POSTGRES_USER=appuser \
  -e POSTGRES_PASSWORD=apppass \
  -v /srv/postgres-data:/var/lib/postgresql/data \
  -v /vagrant/db-init:/docker-entrypoint-initdb.d:ro \
  postgres:16


# backend
docker pull buldosik/devops-backend:1.1

docker run -d \
  --name backend \
  --network devops-net \
  -p 8000:8000 \
  -e POSTGRES_DB=appdb \
  -e POSTGRES_USER=appuser \
  -e POSTGRES_PASSWORD=apppass \
  -e POSTGRES_HOST=devops-postgres \
  -e POSTGRES_PORT=5432 \
  buldosik/devops-backend:1.1

# --- systemd units из отдельных файлов ---
# /vagrant — это шареная папка с хостом, там лежит твой Vagrantfile и .service файлы

cp /vagrant/devops-postgres.service /etc/systemd/system/devops-postgres.service
cp /vagrant/backend.service         /etc/systemd/system/backend.service

systemctl daemon-reload
systemctl enable devops-postgres.service backend.service
# без --now, чтобы не конфликтовать с уже запущенными контейнерами

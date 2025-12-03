terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  # Для Docker Desktop на Windows обычно можно оставить пусто
  # host = "npipe:////./pipe/docker_engine"
}

############################
# NETWORK + VOLUME POSTGRES
############################

resource "docker_network" "devops" {
  name = "devops-net"
}

resource "docker_volume" "postgres_data" {
  name = "devops-postgres-data"
}

############################
# IMAGES
############################

resource "docker_image" "postgres" {
  name        = "postgres:16"
  keep_locally = true
}

resource "docker_image" "backend" {
  name = "buldosik/devops-backend:1.1"
  keep_locally = true
}

############################
# CONTAINER: POSTGRES
############################

resource "docker_container" "postgres" {
  name   = "devops-postgres"
  image  = docker_image.postgres.image_id
  restart = "unless-stopped"

  env = [
    "POSTGRES_USER=user",
    "POSTGRES_PASSWORD=pass",
    "POSTGRES_DB=appdb",
  ]

  networks_advanced {
    name = docker_network.devops.name
  }

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  ports {
    internal = 5432
    external = 5432
  }
}

############################
# CONTAINER: BACKEND
############################

resource "docker_container" "backend" {
  name    = "backend"
  image   = docker_image.backend.image_id
  restart = "unless-stopped"

  # подставь тут те env, которые твой FastAPI реально ждёт
  env = [
    "POSTGRES_HOST=${docker_container.postgres.name}",
    "POSTGRES_PORT=5432",
    "POSTGRES_USER=user",
    "POSTGRES_PASSWORD=pass",
    "POSTGRES_NAME=appdb",
  ]

  networks_advanced {
    name = docker_network.devops.name
  }

  ports {
    internal = 8000
    external = 8000
  }

  depends_on = [docker_container.postgres]
}

############################
# OUTPUT
############################

output "backend_url" {
  value = "http://localhost:8000"
}

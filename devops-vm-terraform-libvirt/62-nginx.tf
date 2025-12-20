locals {
  back_ip = try(module.vm.public_ips["back"][0], "0.0.0.0")
}

resource "local_file" "nginx_config" {
  content = <<-EOT
server {
    listen 8080;
    server_name back.local;

    # http -> https
    return 301 https://$host:8443$request_uri;
}

server {
    listen 8443 ssl;
    server_name back.local;

    ssl_certificate     /etc/nginx/certs/cert.pem;
    ssl_certificate_key /etc/nginx/certs/key.pem;

    location / {
        proxy_pass http://${local.back_ip}:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

EOT 

  # сначала в проект, чтобы не бороться с root-правами
  filename = "${path.module}/nginx-devops.conf"
}
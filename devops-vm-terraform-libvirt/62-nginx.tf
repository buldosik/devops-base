resource "local_file" "nginx_config" {
  content = <<-EOT
server {
    listen 8080;
    server_name back.local;

    location / {
        proxy_pass http://${module.vm["back"].public_ips[0]}:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

server {
    listen 8080;
    server_name dev.local;

    location / {
        proxy_pass http://${module.vm["dev"].public_ips[0]}:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOT

  # сначала в проект, чтобы не бороться с root-правами
  filename = "${path.module}/nginx-devops.conf"
}

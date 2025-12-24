resource "local_file" "ansible_back_vars" {
  content = <<-EOT

  # group_vars/back.yml
  db_host: ${try(module.vm["db"].public_ips[0], "")}
  EOT

  filename = "${path.module}/../ansible/group_vars/back.yml"
}

resource "local_file" "ansible_inventory" {
  content = <<-EOT
  [back]
  ${try(module.vm["back"].public_ips[0], "")} ansible_user=devops

  [db]
  ${try(module.vm["db"].public_ips[0], "")} ansible_user=devops

  [dev]
  ${try(module.vm["dev"].public_ips[0], "")} ansible_user=devops
  EOT

  filename = "${path.module}/../ansible/inventory.ini"
}

resource "local_file" "ansible_back_vars" {
  content = <<-EOT

  # group_vars/back.yml
  db_host: ${try(module.vm["db"].public_ips[0], "")}
  EOT

  filename = "${path.module}/../ansible/group_vars/back.yml"
}

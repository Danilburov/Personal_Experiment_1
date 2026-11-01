# Hand-off to Ansible: the private key and an inventory built from real Terraform values
resource "local_sensitive_file" "ssh_key" {
  content = tls_private_key.ansible.private_key_openssh
  filename = "${path.module}/../ansible/.generated/id_ed25519"
  file_permission = "0600"
}

resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/.generated/inventory.ini"
  content  = <<-EOT
    [k3s_server]
    k3s-server ansible_host=${aws_instance.server.public_ip}

    [k3s_server:vars]
    ansible_user=ubuntu
    ansible_ssh_private_key_file=${abspath(local_sensitive_file.ssh_key.filename)}
  EOT
}

output "server_public_ip" {
  value = aws_instance.server.public_ip
}

output "admin_cidr" {
  description = "The only address allowed to reach SSH and the Kubernetes API"
  value       = local.admin_cidr
}
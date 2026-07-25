output "jenkins_public_ip" {
  description = "Public IP address of the Jenkins server."
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_public_dns" {
  description = "Public DNS name of the Jenkins server."
  value       = aws_instance.jenkins.public_dns
}

output "jenkins_url" {
  description = "Jenkins web URL."
  value       = "http://${aws_instance.jenkins.public_ip}:8080/"
}

output "ansible_inventory_path" {
  description = "Generated Ansible inventory path."
  value       = local_file.ansible_inventory.filename
}

output "ansible_command" {
  description = "Command to configure Jenkins after Terraform apply."
  value       = "cd ../ansible && JENKINS_ADMIN_PASSWORD='replace-me' ansible-playbook playbook.yml"
}

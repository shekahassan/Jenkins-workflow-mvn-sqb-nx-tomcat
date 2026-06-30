output "nexus_url" {
  description = "Nexus Repository URL."
  value       = "http://${aws_instance.servers["nexus"].public_ip}:8081"
}

output "sonarqube_url" {
  description = "SonarQube URL."
  value       = "http://${aws_instance.servers["sonarqube"].public_ip}:9000"
}

output "tomcat_url" {
  description = "Tomcat URL."
  value       = "http://${aws_instance.servers["tomcat_maven"].public_ip}:8080"
}

output "server_public_ips" {
  description = "Public IPs for all servers."
  value = {
    for name, instance in aws_instance.servers : name => instance.public_ip
  }
}

output "ansible_inventory_path" {
  description = "Generated Ansible inventory path."
  value       = local_file.ansible_inventory.filename
}

output "ansible_command" {
  description = "Command to configure the provisioned servers."
  value       = "cd ../ansible && ansible-playbook playbook.yml"
}

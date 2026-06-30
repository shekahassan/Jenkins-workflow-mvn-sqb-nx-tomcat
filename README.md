# Terraform Nexus Ansible Platform

This repository provisions and configures a DevOps tools platform in AWS:

- Sonatype Nexus Repository on its own EC2 server
- SonarQube with local PostgreSQL on its own EC2 server
- Apache Tomcat and Maven on their own EC2 server

Terraform creates the AWS infrastructure in a dedicated VPC and writes a dynamic Ansible inventory. Ansible then installs and configures each service using role-based playbooks.

## Architecture

- Region: `us-east-1`
- SSH key pair: `rancher0529`
- Dedicated VPC with public subnet
- Security groups:
  - SSH `22`
  - Nexus `8081`
  - SonarQube `9000`
  - Tomcat `8080`
- Ubuntu 24.04 LTS EC2 instances

## Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

Terraform writes the generated inventory to:

```text
../ansible/inventory/hosts.ini
```

## Configure Servers

```bash
cd ../ansible
ansible-playbook playbook.yml
```

If a previous run created a root-owned Ansible temp directory and you see an unreachable error for `/tmp/.ansible/tmp` or `/tmp/ansible-ubuntu/tmp`, rerun after pulling the latest code and regenerating the inventory. The project now uses `/home/ubuntu/.ansible/tmp`. If the host still has a locked temp path, remove the old directories once:

```bash
ssh -i ~/.ssh/rancher0529.pem ubuntu@SERVER_PUBLIC_IP 'sudo rm -rf /tmp/.ansible /tmp/ansible-ubuntu && mkdir -p /home/ubuntu/.ansible/tmp && chmod 700 /home/ubuntu/.ansible /home/ubuntu/.ansible/tmp'
```

## Default URLs

Terraform prints service URLs after apply:

- Nexus: `http://NEXUS_PUBLIC_IP:8081`
- SonarQube: `http://SONAR_PUBLIC_IP:9000`
- Tomcat: `http://TOMCAT_PUBLIC_IP:8080`
- Tomcat Manager: `http://TOMCAT_PUBLIC_IP:8080/manager/html`

## Important Production Notes

- Restrict `ssh_allowed_cidr` and `service_allowed_cidr` in `terraform.tfvars`.
- Change `sonarqube_db_password`, `tomcat_admin_password`, and `tomcat_script_password` in Ansible group vars.
- Nexus first admin password is created by Nexus under `/opt/sonatype-work/nexus3/admin.password`.
- SonarQube default web login is `admin/admin` on first login unless changed through the UI.
- Tomcat Manager browser login is configured by Ansible using `tomcat_admin_user` and `tomcat_admin_password`.
- Default Tomcat Manager admin login is `admin` / `admin123`.
- The default admin user is configured with `admin-gui`, `admin-script`, `manager-gui`, `manager-script`, `manager-jmx`, and `manager-status`.
- Tomcat Manager scripted deployment can still use `tomcat_script_user` and `tomcat_script_password` if you prefer separate automation credentials.

## Destroy

```bash
cd terraform
terraform destroy
```
# Jenkins-workflow-mvn-sqb-nx-tmt
# Jenkins-workflow-mvn-sqb-nx-tomcat
# Jenkins-workflow-mvn-sqb-nx-tomcat

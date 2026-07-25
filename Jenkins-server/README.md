# Jenkins Server on AWS with Terraform and Ansible

This project creates a Jenkins controller on AWS in its own VPC, then configures it with Ansible.

## What Terraform Creates

- VPC, public subnet, internet gateway, route table
- Security group allowing SSH `22` and Jenkins `8080`
- EC2 instance type `c7i-flex.large`
- Ubuntu 24.04 LTS AMI
- Encrypted `gp3` root volume
- IAM instance profile with SSM managed instance core by default
- Generated Ansible inventory at `ansible/inventory/hosts.ini`

## What Ansible Installs

- Jenkins LTS from the official Jenkins WAR artifact
- Java 21
- Docker Engine and Docker Compose plugin
- AWS CLI v2
- kubectl
- Helm
- Terraform CLI
- Ansible
- Jenkins DevOps plugins for Pipeline, Git, GitHub, GitLab, Docker, AWS, Kubernetes, Terraform, Ansible, credentials, security, observability, and build utilities

## Prerequisites

- AWS credentials configured locally
- Terraform installed locally
- Ansible installed on the machine where you run the playbook
- Existing AWS key pair named `rancher0529` in `us-east-1`
- Matching private key available locally, for example `~/.ssh/rancher0529.pem`

## Deploy

From this folder:

```bash
cd terraform
terraform init
terraform apply
```

Terraform automatically writes:

```text
../ansible/inventory/hosts.ini
```

Then run Ansible. Use a strong password; the playbook refuses to run without one.

Linux/macOS:

```bash
export JENKINS_ADMIN_PASSWORD='replace-with-a-strong-password'
cd ../ansible
ansible-playbook playbook.yml
```

PowerShell:

```powershell
$env:JENKINS_ADMIN_PASSWORD = 'replace-with-a-strong-password'
cd ..\ansible
ansible-playbook playbook.yml
```

You can also pass it as an extra var:

```bash

```

## Useful Overrides

Create `terraform/terraform.tfvars` from the example if you want to restrict access:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Important variables:

- `ssh_allowed_cidr`: restrict SSH access
- `jenkins_allowed_cidr`: restrict Jenkins UI access
- `ssh_private_key_path`: private key path written into the generated Ansible inventory
- `additional_instance_policy_arns`: attach narrowly scoped AWS policies for Jenkins jobs

After deployment, Terraform prints the Jenkins URL and the exact Ansible command.

## Destroy

```bash
cd terraform
terraform destroy
```
# Jenkins-tf-ans-server

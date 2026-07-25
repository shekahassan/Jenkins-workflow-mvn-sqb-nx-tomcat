variable "project_name" {
  description = "Name prefix used for Jenkins infrastructure resources."
  type        = string
  default     = "jenkins-devops"
}

variable "environment" {
  description = "Environment tag value."
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region where Jenkins will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name."
  type        = string
  default     = "rancher0529"
}

variable "ssh_private_key_path" {
  description = "Private key path that Terraform writes into the generated Ansible inventory."
  type        = string
  default     = "~/.ssh/rancher0529.pem"
}

variable "instance_type" {
  description = "EC2 instance type for the Jenkins server."
  type        = string
  default     = "c7i-flex.large"
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated Jenkins VPC."
  type        = string
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the Jenkins public subnet."
  type        = string
  default     = "10.50.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the public subnet. Leave null to use the first available AZ."
  type        = string
  default     = null
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to access SSH on port 22. Restrict this for production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "jenkins_allowed_cidr" {
  description = "CIDR allowed to access Jenkins on port 8080. Restrict this for production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 30
}

variable "additional_instance_policy_arns" {
  description = "Additional IAM policy ARNs to attach to the Jenkins EC2 role. Keep these narrowly scoped."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags applied to AWS resources."
  type        = map(string)
  default     = {}
}

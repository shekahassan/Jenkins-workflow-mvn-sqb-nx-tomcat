variable "project_name" {
  description = "Project name prefix for AWS resources."
  type        = string
  default     = "liontech-devops-tools"
}

variable "environment" {
  description = "Environment tag."
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name."
  type        = string
  default     = "rancher0529"
}

variable "ssh_private_key_path" {
  description = "Private key path written into generated Ansible inventory."
  type        = string
  default     = "~/.ssh/rancher0529.pem"
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated VPC."
  type        = string
  default     = "10.70.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.70.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone. Leave null to use the first available AZ."
  type        = string
  default     = null
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into all servers. Restrict this in production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "service_allowed_cidr" {
  description = "CIDR allowed to access Nexus, SonarQube, and Tomcat ports. Restrict this in production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "nexus_instance_type" {
  description = "EC2 instance type for Nexus."
  type        = string
  default     = "m7i-flex.large"
}

variable "sonarqube_instance_type" {
  description = "EC2 instance type for SonarQube."
  type        = string
  default     = "m7i-flex.large"
}

variable "tomcat_maven_instance_type" {
  description = "EC2 instance type for Tomcat and Maven."
  type        = string
  default     = "m7i-flex.large"
}

variable "nexus_root_volume_size" {
  description = "Root EBS volume size in GiB for Nexus."
  type        = number
  default     = 50
}

variable "sonarqube_root_volume_size" {
  description = "Root EBS volume size in GiB for SonarQube."
  type        = number
  default     = 50
}

variable "tomcat_maven_root_volume_size" {
  description = "Root EBS volume size in GiB for Tomcat/Maven."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional AWS tags."
  type        = map(string)
  default     = {}
}

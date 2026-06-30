data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

locals {
  name_prefix       = "${var.project_name}-${var.environment}"
  availability_zone = coalesce(var.availability_zone, data.aws_availability_zones.available.names[0])

  servers = {
    nexus = {
      name        = "${local.name_prefix}-nexus"
      type        = var.nexus_instance_type
      volume_size = var.nexus_root_volume_size
      group       = "nexus"
    }
    sonarqube = {
      name        = "${local.name_prefix}-sonarqube"
      type        = var.sonarqube_instance_type
      volume_size = var.sonarqube_root_volume_size
      group       = "sonarqube"
    }
    tomcat_maven = {
      name        = "${local.name_prefix}-tomcat-maven"
      type        = var.tomcat_maven_instance_type
      volume_size = var.tomcat_maven_root_volume_size
      group       = "tomcat_maven"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = local.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "base" {
  name        = "${local.name_prefix}-base-sg"
  description = "Base SSH access for DevOps tool servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    description = "Outbound internet access"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-base-sg"
  }
}

resource "aws_security_group" "nexus" {
  name        = "${local.name_prefix}-nexus-sg"
  description = "Nexus Repository access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Nexus HTTP"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [var.service_allowed_cidr]
  }

  tags = {
    Name = "${local.name_prefix}-nexus-sg"
  }
}

resource "aws_security_group" "sonarqube" {
  name        = "${local.name_prefix}-sonarqube-sg"
  description = "SonarQube access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SonarQube HTTP"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [var.service_allowed_cidr]
  }

  tags = {
    Name = "${local.name_prefix}-sonarqube-sg"
  }
}

resource "aws_security_group" "tomcat_maven" {
  name        = "${local.name_prefix}-tomcat-maven-sg"
  description = "Tomcat access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Tomcat HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.service_allowed_cidr]
  }

  tags = {
    Name = "${local.name_prefix}-tomcat-maven-sg"
  }
}

resource "aws_iam_role" "ec2" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_instance" "servers" {
  for_each = local.servers

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = each.value.type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2.name

  vpc_security_group_ids = concat(
    [aws_security_group.base.id],
    each.key == "nexus" ? [aws_security_group.nexus.id] : [],
    each.key == "sonarqube" ? [aws_security_group.sonarqube.id] : [],
    each.key == "tomcat_maven" ? [aws_security_group.tomcat_maven.id] : []
  )

  root_block_device {
    volume_size = each.value.volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name    = each.value.name
    Service = each.value.group
  }
}

resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory/hosts.ini"
  file_permission = "0644"

  content = templatefile("${path.module}/inventory.tftpl", {
    servers              = aws_instance.servers
    ssh_private_key_path = var.ssh_private_key_path
  })
}

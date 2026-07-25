# Jenkins Workflow: Maven, SonarQube, Nexus, Tomcat

A complete DevOps automation platform for building, testing, analyzing, and deploying Java applications.

## Project Overview

This repository demonstrates a production-ready DevOps workflow that includes:

- **Infrastructure**: Terraform code to provision AWS infrastructure (VPC, EC2, Security Groups)
- **Configuration Management**: Ansible playbooks to install and configure DevOps tools
- **DevOps Tools**: 
  - **Nexus Repository**: Maven artifact repository for binary management
  - **SonarQube**: Code quality and security analysis
  - **Tomcat**: Java application server for deployment
  - **Maven**: Build automation tool (installed on Tomcat server)
- **Sample Application**: Employee Management System (Java/JSP web application)

## Project Structure

```
.
├── README.md                           # Project documentation
├── pom.xml                             # Maven project configuration
├── terraform/                          # Infrastructure as Code
│   ├── main.tf                         # Main infrastructure resources
│   ├── variables.tf                    # Input variables
│   ├── outputs.tf                      # Output values
│   ├── providers.tf                    # AWS provider configuration
│   ├── versions.tf                     # Terraform version constraints
│   ├── terraform.tfvars                # Variable values (generated)
│   ├── terraform.tfstate*              # Terraform state files
│   └── inventory.tftpl                 # Template for Ansible inventory
├── ansible/                            # Configuration Management
│   ├── ansible.cfg                     # Ansible configuration
│   ├── playbook.yml                    # Main playbook
│   ├── inventory/
│   │   └── hosts.ini                   # Generated inventory (from Terraform)
│   ├── group_vars/                     # Group-level variables
│   │   ├── all.yml                     # Global variables
│   │   ├── nexus.yml                   # Nexus-specific variables
│   │   ├── sonarqube.yml               # SonarQube-specific variables
│   │   └── tomcat_maven.yml            # Tomcat/Maven-specific variables
│   └── roles/                          # Ansible roles
│       ├── common/                     # Common setup (Java, utilities)
│       ├── nexus/                      # Nexus installation & config
│       ├── sonarqube/                  # SonarQube installation & config
│       └── tomcat_maven/               # Tomcat & Maven installation
├── src/                                # Application source code
│   └── main/
│       ├── java/                       # Java source files
│       └── webapp/
│           └── index.jsp               # JSP application page
└── target/                             # Build output (generated)
```

## Prerequisites

### Local Machine

- **Terraform** >= 1.0 (for infrastructure provisioning)
- **Ansible** >= 2.10 (for configuration management)
- **AWS CLI** (for AWS interactions)
- **SSH keys** in `~/.ssh/` directory
- **Maven** >= 3.6 (for local builds - optional)
- **Git** (for version control)

### AWS Account

- Valid AWS credentials configured
- Appropriate IAM permissions to create EC2, VPC, Security Groups, and IAM resources
- Region: `us-east-2` (configurable in `terraform/variables.tf`)

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd Jenkins-workflow-mvn-sqb-nx-tomcat
```

### 2. Configure AWS Credentials

```bash
aws configure
# or set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY environment variables
```

### 3. Initialize Terraform

```bash
cd terraform
terraform init
```

### 4. Create terraform.tfvars

Copy the example and customize as needed:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars to customize region, instance types, CIDR blocks, etc.
```

### 5. Provision Infrastructure

```bash
terraform plan
terraform apply
```

This creates:
- EC2 instances for Nexus, SonarQube, and Tomcat/Maven
- VPC and security groups
- Dynamic Ansible inventory

**Output**: Service URLs and instance IPs

### 6. Configure Services with Ansible

```bash
cd ../ansible
ansible-playbook playbook.yml
```

This installs and starts:
- Nexus Repository Manager
- SonarQube with PostgreSQL database
- Tomcat and Maven

### 7. Access Services

After deployment, services are available at the URLs provided by Terraform:

```
Nexus:         http://<NEXUS_IP>:8081
SonarQube:     http://<SONARQUBE_IP>:9000
Tomcat:        http://<TOMCAT_IP>:8080
Tomcat Manager: http://<TOMCAT_IP>:8080/manager/html
```

## Employee Application

A sample Java web application (JSP) that demonstrates deployment on Tomcat.

### Build Locally

```bash
mvn clean package
# Creates: target/employee-app-1.0.0.war
```

### Deploy to Tomcat

Option 1: Upload WAR via Tomcat Manager UI
- Navigate to: `http://<TOMCAT_IP>:8080/manager/html`
- Login with configured admin credentials
- Deploy the WAR file

Option 2: SSH and deploy directly
```bash
ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<TOMCAT_IP>
scp -i ~/.ssh/ansible-devops-key.pem target/employee-app-1.0.0.war ubuntu@<TOMCAT_IP>:/tmp/
# Then upload via Tomcat Manager or copy to /opt/tomcat/webapps/
```

### Access the Application

```
http://<TOMCAT_IP>:8080/employee-app-1.0.0/
```

## Architecture

### AWS Infrastructure

- **Region**: `us-east-2` (configurable)
- **VPC**: Dedicated VPC with public subnet (`10.70.0.0/16`)
- **EC2 Instances**: Ubuntu 24.04 LTS (m7i-flex.large)
  - **Nexus Server**: Port 8081
  - **SonarQube Server**: Port 9000 (with PostgreSQL database)
  - **Tomcat/Maven Server**: Ports 8080, 8443
- **Security Groups**:
  - SSH (22) - configurable CIDR
  - Service ports - configurable CIDR
  - Egress: Full internet access (0.0.0.0/0)
- **SSH Key Pair**: `ansible-devops-key` (stored at `~/.ssh/ansible-devops-key.pem`)
- **IAM**: EC2 instances with SSM (Systems Manager) role for secure shell access

### DevOps Workflow

```
┌──────────────┐
│ Source Code  │
│   (Git)      │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────┐
│ Build & Package (Maven)      │
│ - Compile Java code          │
│ - Run tests                  │
│ - Create WAR artifact        │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ Code Analysis (SonarQube)    │
│ - Code quality metrics       │
│ - Security scanning          │
│ - Code coverage              │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ Artifact Repository (Nexus)  │
│ - Store WAR artifacts        │
│ - Maven dependency caching   │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│ Deploy (Tomcat)              │
│ - Host Java web applications │
│ - Application server         │
└──────────────────────────────┘
```

```bash
cd terraform
terraform init
terraform apply
```

Terraform writes the generated inventory to:

```text
../ansible/inventory/hosts.ini
```

## Detailed Deployment Steps

### Step 1: Deploy Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

Terraform creates:
- EC2 instances for Nexus, SonarQube, and Tomcat/Maven
- VPC and security groups
- Dynamic Ansible inventory at `../ansible/inventory/hosts.ini`

Output includes service URLs and public IPs.

### Step 2: Configure Servers

```bash
cd ../ansible
ansible-playbook playbook.yml
```

This runs the following roles:

1. **common** - Applied to all servers:
   - Wait for SSH connectivity
   - Set timezone
   - Update system packages
   - Install Java 17 runtime
   - Configure systemd

2. **nexus** - Nexus Repository server:
   - Download & extract Nexus OSS
   - Configure systemd service
   - Set JVM heap memory (1200m default)
   - Enable and start Nexus
   - Wait for HTTP endpoint

3. **sonarqube** - SonarQube server:
   - Install PostgreSQL database
   - Configure kernel parameters for SonarQube
   - Download & extract SonarQube
   - Configure database connection
   - Enable and start SonarQube
   - Wait for HTTP endpoint

4. **tomcat_maven** - Tomcat & Maven server:
   - Install Tomcat 10 and Maven 3.8.7
   - Configure Tomcat manager users
   - Set up Tomcat service
   - Enable and start Tomcat
   - Verify Maven installation

### Fixing Temporary Directory Issues

If you see an unreachable error for `/tmp/.ansible/tmp`:

```bash
ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<SERVER_PUBLIC_IP> 'sudo rm -rf /tmp/.ansible /tmp/ansible-ubuntu && mkdir -p /home/ubuntu/.ansible/tmp && chmod 700 /home/ubuntu/.ansible /home/ubuntu/.ansible/tmp'
```

Then rerun the playbook:

```bash
ansible-playbook playbook.yml
```

## Service Access & Credentials

### Default URLs

After successful deployment, services are accessible at:

- **Nexus**: `http://<NEXUS_IP>:8081`
- **SonarQube**: `http://<SONARQUBE_IP>:9000`
- **Tomcat**: `http://<TOMCAT_IP>:8080`
- **Tomcat Manager**: `http://<TOMCAT_IP>:8080/manager/html`

### Default Credentials & Passwords

**Nexus**:
- First admin password: Stored at `/opt/sonatype-work/nexus3/admin.password` on the Nexus server
- Retrieve with: `ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<NEXUS_IP> 'sudo cat /opt/sonatype-work/nexus3/admin.password'`

**SonarQube**:
- Default login: `admin` / `admin`
- Change password on first login from the UI

**Tomcat Manager**:
- Browser login: `admin` / (configured in `ansible/group_vars/tomcat_maven.yml`)
- Script deployment: `deployer` / (configured in `ansible/group_vars/tomcat_maven.yml`)

## Production Considerations

- **Security**: Restrict `ssh_allowed_cidr` and `service_allowed_cidr` in `terraform/terraform.tfvars` to your trusted IP ranges
- **Passwords**: Change all default passwords in `ansible/group_vars/*.yml` before deploying to production
- **Database**: SonarQube uses a local PostgreSQL database; consider external database for high availability
- **Monitoring**: Set up CloudWatch monitoring and alarms for EC2 instances
- **Backups**: Implement backup strategy for Nexus artifacts and SonarQube data
- **SSL/TLS**: Configure HTTPS certificates for all services (requires load balancer or reverse proxy)
- **Network**: Consider using private subnets with VPN/bastion for management access

## Destroy

```bash
cd terraform
terraform destroy
```

This will terminate all EC2 instances and delete the VPC and related resources.

## Development Workflow

### Building the Employee Application Locally

```bash
# Build and package the application
mvn clean package

# Run tests
mvn test

# Create deployable WAR
mvn clean package -DskipTests

# The WAR file is created at: target/employee-app-1.0.0.war
```

### Deploying to Nexus

```bash
# Configure Nexus credentials in ~/.m2/settings.xml
# Then deploy to Nexus repository
mvn deploy

# Or deploy a specific artifact
mvn deploy:deploy-file -DgroupId=com.company -DartifactId=employee-app \
  -Dversion=1.0.0 -Dpackaging=war -Dfile=target/employee-app-1.0.0.war \
  -Durl=http://<NEXUS_IP>:8081/repository/releases \
  -DrepositoryId=nexus-releases
```

### Code Quality Analysis

```bash
# Run SonarQube analysis
mvn sonar:sonar \
  -Dsonar.projectKey=employee-app \
  -Dsonar.sources=src/main \
  -Dsonar.host.url=http://<SONARQUBE_IP>:9000 \
  -Dsonar.login=<SONARQUBE_TOKEN>
```

### Deploying to Tomcat

**Option 1: Via Tomcat Manager UI**
1. Navigate to `http://<TOMCAT_IP>:8080/manager/html`
2. Log in with Tomcat admin credentials
3. Upload the WAR file using the "Deploy" section

**Option 2: Via Maven Plugin**
```bash
mvn cargo:deploy -Dcargo.remote.url=http://<TOMCAT_IP>:8080/manager/text
```

**Option 3: Direct File Copy**
```bash
scp -i ~/.ssh/ansible-devops-key.pem target/employee-app-1.0.0.war \
  ubuntu@<TOMCAT_IP>:/opt/tomcat/webapps/
```

## Useful Commands

### SSH into Servers

```bash
# Nexus server
ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<NEXUS_IP>

# SonarQube server
ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<SONARQUBE_IP>

# Tomcat/Maven server
ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<TOMCAT_IP>
```

### Retrieve Terraform Outputs

```bash
cd terraform
terraform output server_public_ips
terraform output nexus_url
terraform output sonarqube_url
terraform output tomcat_url
```

### Re-run Ansible Playbook

```bash
cd ansible
# Full playbook
ansible-playbook playbook.yml

# Specific role only
ansible-playbook playbook.yml -k nexus

# Specific host
ansible-playbook playbook.yml -l liontech-devops-tools-prod-nexus

# Verbose output
ansible-playbook playbook.yml -vv
```

### Verify Service Status

```bash
# From local machine
ansible all -m command -a "systemctl status nexus" -i ansible/inventory/hosts.ini
ansible all -m command -a "systemctl status sonarqube" -i ansible/inventory/hosts.ini
ansible all -m command -a "systemctl status tomcat10" -i ansible/inventory/hosts.ini

# Or SSH directly
ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<SERVER_IP> 'sudo systemctl status <service>'
```

### View Service Logs

```bash
# Nexus logs
ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<NEXUS_IP> 'tail -f /opt/nexus-3.*/logs/nexus.log'

# SonarQube logs
ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<SONARQUBE_IP> 'tail -f /var/log/sonarqube/sonarqube.log'

# Tomcat logs
ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<TOMCAT_IP> 'tail -f /opt/tomcat/logs/catalina.out'
```

### SSH Key Mismatch Error

**Problem:** `Permission denied (publickey)` when running Ansible playbook

**Cause:** Occurs when the EC2 instances were created with a different SSH key pair than what Ansible is configured to use.

**Solution:**

1. Verify the SSH key in `terraform.tfvars`:
   ```bash
   cd terraform
   cat terraform.tfvars | grep key_name
   ```

2. Ensure the corresponding private key exists:
   ```bash
   ls -la ~/.ssh/ansible-devops-key.pem
   ```

3. If the key doesn't match, update `terraform.tfvars` and recreate instances:
   ```bash
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

4. Test connectivity:
   ```bash
   cd ../ansible
   ansible all -m ping
   ```

### Unreachable Hosts During Playbook Run

If you see `UNREACHABLE!` errors:

1. Verify SSH connectivity manually:
   ```bash
   ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<PUBLIC_IP> 'echo test'
   ```

2. Check Ansible inventory file (`ansible/inventory/hosts.ini`) has correct IPs and key path

3. Regenerate inventory from Terraform:
   ```bash
   cd terraform
   terraform apply -auto-approve
   cd ../ansible
   ansible all -m ping
   ```

### Services Not Starting

**Problem**: Nexus/SonarQube/Tomcat service fails to start

**Diagnosis**:
```bash
ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<SERVER_IP>
sudo systemctl status <service>
sudo journalctl -u <service> -n 50
```

**Common causes & solutions**:
- **Port already in use**: Change port in service configuration or security groups
- **Insufficient disk space**: Expand EBS volume or clean up logs
- **Memory issues**: Increase instance type or adjust JVM heap settings in `group_vars/`
- **Database not ready** (SonarQube): Wait 2-3 minutes for PostgreSQL to initialize

### Terraform State Issues

**Problem**: "Error: Resource already exists" or state conflicts

**Solution**:
```bash
cd terraform
# Refresh Terraform state
terraform refresh

# Or rebuild from scratch
terraform destroy -auto-approve
rm terraform.tfstate* .terraform/terraform.tfstate*
terraform init
terraform apply
```

### Ansible Inventory Not Generated

**Problem**: `hosts.ini` is missing or outdated

**Solution**:
```bash
cd terraform
terraform apply -target=local_file.ansible_inventory

# Or manually regenerate
terraform taint local_file.ansible_inventory
terraform apply
```

### Services Unreachable from Outside

**Problem**: Cannot access Nexus/SonarQube/Tomcat from browser

**Check**:
1. Security group allows inbound traffic on the service port:
   ```bash
   aws ec2 describe-security-groups --region us-east-2 --query 'SecurityGroups[?contains(GroupName, `devops-tools`)].IpPermissions'
   ```

2. Instance is running:
   ```bash
   aws ec2 describe-instances --region us-east-2 --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]'
   ```

3. Service is listening:
   ```bash
   ssh -i ~/.ssh/ansible-devops-key.pem ubuntu@<SERVER_IP> 'sudo netstat -tlnp | grep :8081'
   ```

4. Try connecting with curl:
   ```bash
   curl -v http://<PUBLIC_IP>:8081
   ```

## Support & Documentation

- **Terraform Docs**: https://www.terraform.io/docs
- **Ansible Docs**: https://docs.ansible.com/
- **Nexus Docs**: https://help.sonatype.com/repomanager3
- **SonarQube Docs**: https://docs.sonarsource.com/sonarqube/latest/
- **Tomcat Docs**: https://tomcat.apache.org/
- **Maven Docs**: https://maven.apache.org/

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature/your-feature`
5. Submit a pull request

## License

This project is provided as-is for educational and commercial use.

# rsschool-devops-course-tasks
English Version: GitHub Actions: Terraform AWS Deploy
This GitHub Actions workflow is designed to automate the validation, planning, and application of your Terraform configurations to AWS. It ensures your infrastructure changes are formatted correctly, planned thoroughly, and applied securely using an IAM Role assumed via OIDC.

Purpose & Features
Code Quality Check: Automatically formats and checks your Terraform code for consistency.
Secure AWS Authentication: Assumes an AWS IAM Role via OpenID Connect (OIDC), eliminating the need for static AWS credentials in your repository.
Dynamic Backend Configuration: Generates the S3 backend configuration on the fly using secrets for the correct bucket name.
Environment-Specific Deployments: Supports different environments (dev, prod) by loading environment-specific Terraform variable files (terraform.<env>.tfvars) and dynamically fetching associated secrets.
Plan Review: Creates and uploads a tfplan artifact, allowing for manual review of proposed changes before automatic application to main.
Controlled Application: Automatically applies changes only on push to the main branch, ensuring a more controlled deployment pipeline.
Prerequisites
Before running this workflow, ensure you have:

Terraform Code: Your Terraform .tf files and terraform.<env>.tfvars files (e.g., terraform.dev.tfvars, terraform.prod.tfvars) in your repository.
Bootstrap Infrastructure: The S3 bucket for Terraform state and the OIDC-enabled IAM Role (e.g., GH_ROLE_ARN_dev, GH_ROLE_ARN_prod) must already be created, ideally by a preceding bootstrap workflow.
GitHub Secrets: The following secrets must be available in your repository (set by the bootstrap workflow):
TF_BUCKET_NAME_dev: S3 bucket name for dev environment.
GH_ROLE_ARN_dev: IAM Role ARN for dev environment.
TF_BUCKET_NAME_prod: S3 bucket name for prod environment.
GH_ROLE_ARN_prod: IAM Role ARN for prod environment.
Workflow Structure
This workflow consists of three main jobs:

terraform-check: Runs terraform fmt -check -recursive to ensure code formatting compliance.
terraform-plan:
Checks out the code.
Dynamically selects and exports the correct S3 bucket name and IAM Role ARN based on the TF_ENV (defaults to dev).
Configures AWS credentials by assuming the specified OIDC role.
Generates a backend.tf file for S3 state.
Validates the presence of terraform.<ENV>.tfvars.
Runs terraform init and terraform validate.
Creates a tfplan file and uploads it as an artifact.
terraform-apply:
Conditional Run: Only runs on push events to the main branch.
Similar setup steps to terraform-plan (checkout, setup Terraform, export secrets, configure AWS credentials, generate backend).
Downloads the tfplan artifact from the terraform-plan job.
Applies the tfplan to your AWS environment.
How to Use
Set Environment Variables:

The TF_ENV environment variable defaults to "dev". You can change this directly in the workflow file or override it via workflow_dispatch if you modify the input section.
Ensure your terraform.<env>.tfvars files exist for each environment you intend to deploy to (e.g., terraform.dev.tfvars, terraform.prod.tfvars).
Trigger the Workflow:

Automatic:
Push changes to the main branch (will trigger check, plan, and apply).
Push changes to any branch matching task_* (will trigger check and plan only).
Manual: Go to the "Actions" tab in your repository, select "Terraform AWS Deploy" from the workflows list, and click "Run workflow". Note that manual runs will only perform check and plan unless you adjust the terraform-apply condition.
Monitor Execution: Observe the workflow run in the GitHub Actions tab. Review the terraform-plan output and the tfplan artifact carefully before applying changes to main.


task_1

## Terraform AWS Deployment with GitHub Actions

### 📌 Description

This project automates AWS infrastructure deployment using **Terraform** and **GitHub Actions**, as part of a DevOps training task.

### ✅ Objectives

- Install and configure AWS CLI and Terraform locally.
    
- Create IAM user with required policies and MFA.
    
- Deploy an S3 bucket for storing Terraform state.
    
- Configure GitHub Actions workflow for Terraform deployment.
    
- (Optional) Configure OIDC federation and IAM role for GitHub.
    

---

### 🛠️ Stack

- **Terraform v1.6+**
    
- **AWS CLI v2**
    
- **GitHub Actions**
    
- **IAM**, **S3**
    

---

### 🚀 GitHub Actions Workflow

File: `.github/workflows/terraform-deploy.yml`

It includes 3 jobs:

1. **terraform-check** — format check using `terraform fmt`
    
2. **terraform-plan** — infrastructure planning with `terraform plan`
    
3. **terraform-apply** — apply infrastructure changes on `push` to `main`
    

---


    

---

### 🧪 Verification & Submission

- ✅ `terraform plan` runs successfully
    
- ✅ GitHub Actions workflows are passing
    
- ✅ Screenshots with:
    
    - `aws --version`
        
    - `terraform version`
        
- ✅ PR from `task_1` to `main` includes all code and outputs

📁 Structure
.

task_2


What does this project do?
This Terraform project deploys the following AWS infrastructure:

Identity and Access Management (IAM):
Creates an IAM group named rs.school.
Attaches several standard AWS full-access policies (e.g., AmazonEC2FullAccess, AmazonS3FullAccess, IAMFullAccess, and others) to this group to provide broad permissions for development purposes.
Creates an IAM user my_user_task1 and adds it to the rs.school group.
Terraform State Storage:
Creates an S3 bucket (terraform_state) for reliable remote storage of Terraform state.
Enables versioning for this bucket, ensuring the ability to roll back to previous states and protection against accidental deletion.
Compute Resources (EC2):
Deploys a Bastion/NAT Instance (vm-bastion-nat): this is a public VM (with a public IP) that serves as an entry point to the private network (bastion) and as a NAT gateway for private resources, allowing them to initiate outbound connections to the internet without a direct public IP. Source/destination checking (source_dest_check) is disabled for this instance.
Deploys a Public VM (vm-public-vm): this is a VM with a public IP, located in a public subnet.
Deploys two Private VMs (vm-private-vm-1, vm-private-vm-2): these VMs are located in private subnets, do not have a direct public IP, and access the internet via the Bastion/NAT Instance.
Networking Components (VPC, NACLs, Security Groups):
Configures Network Access Control Lists (NACLs) for public and private subnets, defining rules for inbound and outbound traffic (SSH, ICMP, ephemeral ports, VPC internal traffic).
Configures Security Groups for each VM group (Bastion/NAT, Public, Private), controlling traffic at the instance level. For example, private VMs are only accessible via SSH from the bastion host.
Creates routes for private subnets, directing all outbound traffic through the NAT Instance.
Connecting to Hosts using SSH Agent
For secure and convenient connection to your EC2 instances, it is recommended to use ssh-agent. This allows you to load your private key once and use it for all subsequent SSH connections without needing to enter a password or specify the key file path each time.

Prerequisites:

Before deploying the infrastructure, you must create two SSH key pairs in AWS:

A key for bastion-key (to be used for the Bastion/NAT Instance).
A key for vm-key (to be used for the Public and Private VMs).
Ensure that the public parts of these keys (.pub files) are correctly imported into AWS EC2. The private parts of the keys (.pem files) should be stored locally.

Connection Steps:

Start ssh-agent:

Bash

eval "$(ssh-agent -s)"
(On Windows, use Git Bash or WSL for this command. In PowerShell, the command will be Start-SshAgent followed by ssh-add.)

Add your private keys to ssh-agent:

Bash

ssh-add /path/to/your/bastion-key.pem
ssh-add /path/to/your/vm-key.pem
Replace /path/to/your/ with the actual path to your .pem files.

Connect to the Bastion/NAT Instance:
First, you need to connect to the bastion host using its public DNS name, which will be assigned by AWS after Terraform deployment.

Bash

ssh -A ec2-user@<Public_DNS_Name_of_Bastion_NAT_VM>
The -A flag is crucial as it enables agent forwarding, allowing you to use the same SSH key for subsequent connections from the bastion host to other private VMs.
ec2-user is the default username for Amazon Linux-based AMIs. If you are using a different AMI, the username may vary (e.g., ubuntu, centos, admin).
From the Bastion Host, connect to Private/Public VMs:
Once successfully connected to the bastion host, you can use it to access internal VMs using their private DNS names or IP addresses. Thanks to ssh-agent forwarding, 
you do not need to copy the private key to the bastion host.

Bash

# From the bastion host
ssh ec2-user@<internal_public_vm_private_ip>
ssh ec2-user@<private_vm_private_ips >
ssh ec2-user@<private_vm_private_ips >
Note: We are utilizing the free DNS names provided by AWS for our EC2 instances, and NOT Elastic IPs, which incur charges under certain usage conditions.
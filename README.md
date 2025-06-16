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


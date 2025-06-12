# rsschool-devops-course-tasks

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

### 🔐 OIDC Federation (Optional)

Created:

- **OIDC Provider** for `https://token.actions.githubusercontent.com`
    
- **IAM Role** `GithubActionsRole` with trust policy restricted to the current repo
    

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
├── main.tf
├── iam.tf
├── OIDC.tf
├── variables.tf
├── terraform.tfvars
├── README.md
└── .github/workflows/terraform-deploy.yml


The `iam.tf` file sets up:

- An OIDC identity provider for GitHub Actions.
    
- An IAM role `GithubActionsRole` that can be assumed by GitHub Actions via OIDC.
    
- A trust policy restricting access to a specific repository.
    
- Attaches AWS managed policies to the role for infrastructure management.
    

This allows secure authentication from GitHub Actions to AWS without long-lived credentials.

- An IAM group with a predefined set of AWS managed policies.
    
- An IAM user.
    
- Assigns the user to the group.
    

The attached policies provide full access to services like EC2, S3, IAM, VPC, Route53, SQS, and EventBridge.


### `OIDC.tf` – GitHub Actions OIDC Integration

This file sets up OpenID Connect (OIDC) authentication between GitHub Actions and AWS:

- **Retrieves the current AWS account ID** (used to construct ARNs).
    
- **Creates an OIDC provider** for GitHub (`token.actions.githubusercontent.com`).
    
- **Creates an IAM role** (`GithubActionsRole`) that GitHub Actions can assume using OIDC.
    
- **Attaches AWS managed policies** (e.g., S3, EC2, IAM) to the role.
    
- **Uses conditions** to restrict access only to a specific repository.
    

This setup allows GitHub Actions to securely access AWS resources without static credentials.

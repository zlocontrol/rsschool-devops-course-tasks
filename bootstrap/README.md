### GitHub Actions: AWS Bootstrap & OIDC Role

This GitHub Actions workflow automates the initial setup of core AWS infrastructure required for Terraform deployments, specifically creating an S3 bucket for Terraform state and an AWS IAM Role for subsequent GitHub Actions using OpenID Connect (OIDC).

### Purpose & Features
Initial AWS Setup: Automates the creation of an S3 bucket to store Terraform state, crucial for managing your infrastructure.
Secure OIDC Integration: Configures an AWS IAM Role that GitHub Actions can securely assume using OIDC, eliminating the need for long-lived AWS credentials in your workflows.
Dynamic Credential Management: Extracts key outputs (S3 bucket name, IAM Role ARN) from Terraform and saves them as GitHub Secrets for use in other workflows, dynamically named based on the environment.
Controlled Deployment: Triggerable via push to specific branches or manually, allowing for clear control over when bootstrap infrastructure is deployed or updated.
### Prerequisites
Before running this workflow, ensure you have:

AWS Account: An active AWS account where resources will be deployed.
GitHub Repository: The repository where this workflow and your Terraform code reside.
AWS Bootstrap Credentials:
An AWS IAM User with programmatic access (Access Key ID and Secret Access Key) and sufficient permissions to create S3 buckets, IAM OIDC Providers, and IAM Roles.
These credentials should be stored as GitHub Secrets:
BOOTSTRAP_ACCESS_KEY_ID
BOOTSTRAP_SECRET_ACCESS_KEY
GitHub Personal Access Token (PAT):
A GitHub PAT with repo scope to set repository secrets.
Store this as a GitHub Secret: GH_ADMIN_PAT
Terraform Configuration:
Your Terraform code for the S3 bucket and IAM role should be located in the bootstrap/ directory within your repository.
The bootstrap/terraform.tfvars file should define variables like role_name, environment, github_repo_owner, github_repo_name.
Workflow Inputs
When triggering the workflow manually (workflow_dispatch), you can provide:

tf_env: The Terraform environment (e.g., dev, prod). This value will be used to sanitize the name of the GitHub Secrets.
Secrets Used
BOOTSTRAP_ACCESS_KEY_ID: AWS Access Key ID for initial infrastructure creation.
BOOTSTRAP_SECRET_ACCESS_KEY: AWS Secret Access Key for initial infrastructure creation.
GH_ADMIN_PAT: GitHub PAT with repo scope to set repository secrets.
How to Use
Place Terraform Code: Ensure your Terraform .tf files for the S3 bucket and IAM Role are in a bootstrap/ directory at the root of your repository.

Crucially: In your bootstrap/terraform.tfvars file, set create_oidc_provider = true for the very first run to create the OIDC provider.
For subsequent runs, change this to create_oidc_provider = false to prevent errors about the provider already existing.
Trigger the Workflow:

Automatic: Push changes to a branch matching the pattern create/** (e.g., create/dev, create/prod).
Manual: Go to the "Actions" tab in your repository, select "Bootstrap Infra and GitHub Role" from the workflows list, and click "Run workflow," providing the tf_env input.
Monitor Execution: Observe the workflow run in the GitHub Actions tab.

Verify Outputs: After successful completion, verify that new GitHub Secrets named TF_BUCKET_NAME_<ENV> and GH_ROLE_ARN_<ENV> (where <ENV> is your tf_env in uppercase) have been created in your repository settings.

### Important Considerations
##### Bootstrap Credentials Security: The BOOTSTRAP_ACCESS_KEY_ID and BOOTSTRAP_SECRET_ACCESS_KEY used in this workflow are highly privileged. Treat them with extreme care and ensure they have only the minimum necessary permissions. Consider rotating them regularly.
OIDC Thumbprint: The OIDC provider's thumbprint_list in your Terraform code (6938fd4d98bab03faadb97b34396831e3780fa86) might become outdated. If you encounter errors during OIDC provider creation or validation, you'll need to update this value to the latest thumbprint for https://token.actions.githubusercontent.com.








AWS IAM Role for GitHub Actions (OIDC)
This Terraform module configures an AWS IAM Role that GitHub Actions can assume via OpenID Connect (OIDC).
This enables secure access to AWS resources from your GitHub workflows without static credentials.

It allows you to either create a new OIDC provider for token.actions.githubusercontent.com or reference an existing one, controlled by the create_oidc_provider variable.

Usage:
Variables: Define create_oidc_provider, role_name, environment, github_repo_owner, and github_repo_name.

### First Run:

Set **`create_oidc_provider = true`**.
Run terraform init, terraform plan, terraform apply.
Subsequent Runs:

After the OIDC provider is created, set `create_oidc_provider = false`.
Run terraform plan, terraform apply. This prevents re-creation and references the existing provider.
Important: thumbprint_list
The thumbprint_list is mandatory. The provided 6938fd4d98bab03faadb97b34396831e3780fa86 might become outdated. 
If you encounter errors, update it to the latest thumbprint for token.actions.githubusercontent.com.
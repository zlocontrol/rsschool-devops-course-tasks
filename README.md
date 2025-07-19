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
- TF_BUCKET_NAME_dev: S3 bucket name for dev environment.
- GH_ROLE_ARN_dev: IAM Role ARN for dev environment.
- TF_BUCKET_NAME_prod: S3 bucket name for prod environment.
- GH_ROLE_ARN_prod: IAM Role ARN for prod environment.

#### Workflow Structure
This workflow consists of three main jobs:

- terraform-check: Runs terraform fmt -check -recursive to ensure code formatting compliance.
- terraform-plan:

#### Checks out the code.
Dynamically selects and exports the correct S3 bucket name and IAM Role ARN based on the TF_ENV (defaults to dev).
Configures AWS credentials by assuming the specified OIDC role.
Generates a backend.tf file for S3 state.
Validates the presence of terraform.*<ENV>*.tfvars.
Runs terraform init and terraform validate.
Creates a tfplan file and uploads it as an artifact.
- terraform-apply:

Conditional Run: Only runs on push events to the main branch.
Similar setup steps to terraform-plan (checkout, setup Terraform, export secrets, configure AWS credentials, generate backend).
Downloads the tfplan artifact from the terraform-plan job.
Applies the tfplan to your AWS environment.
How to Use
Set Environment Variables:

The TF_ENV environment variable defaults to "dev". You can change this directly in the workflow file or override it via workflow_dispatch if you modify the input section.
Ensure your `terraform.<env>.tfvars` files exist for each environment you intend to deploy to (e.g., terraform.dev.tfvars, terraform.prod.tfvars).
Trigger the Workflow:

Automatic:
Push changes to the main branch (will trigger check, plan, and apply).
Push changes to any branch matching task_* (will trigger check and plan only).
Manual: Go to the "Actions" tab in your repository, select "Terraform AWS Deploy" from the workflows list, and click "Run workflow". Note that manual runs will only perform check and plan unless you adjust the terraform-apply condition.
Monitor Execution: Observe the workflow run in the GitHub Actions tab. Review the terraform-plan output and the tfplan artifact carefully before applying changes to main.


# task_1

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
---
# task_2


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

### Prerequisites:

#### Before deploying the infrastructure, you must create two SSH key pairs in AWS:

- A key for bastion-key (to be used for the Bastion/NAT Instance).
- A key for vm-key (to be used for the Public and Private VMs).
- Ensure that the public parts of these keys (.pub files) are correctly imported into AWS EC2. The private parts of the keys (.pem files) should be stored locally.

### Connection Steps:

- Start ssh-agent:



` eval "$(ssh-agent -s)" `


(On Windows, use Git Bash or WSL for this command.
In PowerShell, the command will be Start-SshAgent followed by ssh-add.)

- Add your private keys to ssh-agent:


```Bash

ssh-add /path/to/your/bastion-key.pem
ssh-add /path/to/your/vm-key.pem

```
#### Replace /path/to/your/ with the actual path to your .pem files.

### Connect to the Bastion/NAT Instance:
First, you need to connect to the bastion host using its public DNS name, which will be assigned by AWS after Terraform deployment.


`ssh -A ec2-user@<Public_DNS_Name_of_Bastion_NAT_VM>` 

The -A flag is crucial as it enables agent forwarding, allowing you to use the same SSH key for subsequent connections from the bastion host to other private VMs.
ec2-user is the default username for Amazon Linux-based AMIs. If you are using a different AMI, the username may vary (e.g., ubuntu, centos, admin).
From the Bastion Host, connect to Private/Public VMs:
Once successfully connected to the bastion host, you can use it to access internal VMs using their private DNS names or IP addresses. Thanks to ssh-agent forwarding, 
you do not need to copy the private key to the bastion host.


### From the bastion host
```bash
ssh ec2-user@<internal_public_vm_private_ip>
ssh ec2-user@<private_vm_private_ips >
ssh ec2-user@<private_vm_private_ips >
```
### Note: We are utilizing the free DNS names provided by AWS for our EC2 instances,
### and NOT Elastic IPs, which incur charges under certain usage conditions.

----

# task_3

## K3s Cluster Deployment in AWS with Terraform
This repository contains Terraform code for the automated deployment of a lightweight Kubernetes (K3s) cluster on Amazon Web Services (AWS). The cluster consists of one master node and one agent node, running on EC2 instances located in private subnets behind a Bastion/NAT instance.

Table of Contents
Architecture Overview

Prerequisites

Project Structure

Deployment Configuration (Variables)

Cluster Deployment

Terraform Initialization

Planning and Application

Accessing the Cluster

Access via Bastion Host

Access from Local Computer

Cluster Verification

Workload Deployment

Resource Cleanup

Troubleshooting (Key Debugging Points)

Architecture Overview
- The K3s cluster is deployed within a specially configured VPC with public and private subnets:

- VPC (Virtual Private Cloud): An isolated network environment within AWS.

- Public Subnets: Contain the Bastion/NAT instance. They have Internet access via an Internet Gateway.

- Private Subnets: Contain the K3s Master and K3s Agent nodes. Internet access is only possible via the NAT Gateway deployed in the public subnet.

- Bastion/NAT Host: A single entry point into the private subnets for SSH and acts as a NAT Gateway for outbound traffic from private instances.

- K3s Master Node: Runs the K3s Server, which is the Kubernetes Control Plane for the cluster.

- K3s Agent Node: Runs the K3s Agent, which is a Worker Node of the Kubernetes cluster.

- Security Groups & Network ACLs: Configured to ensure secure and necessary network communication between components.

- IAM Roles: Grant EC2 instances the required permissions (e.g., access to AWS SSM Parameter Store to retrieve the K3s token).

- AWS SSM Parameter Store: Used for secure storage of the K3s token generated by Terraform.

Prerequisites
An AWS account with configured credentials (AWS CLI configured).

Terraform installed (version 1.0+).

#### SSH keys available for accessing EC2 instances (recommended to add them to ssh-agent).

kubectl installed on your local computer.

ssh-agent running and your SSH key added.
````
Project Structure
.
├── main.tf                 # Root Terraform module, main infrastructure plan
├── variables.tf            # Global Terraform variables
├── terraform.tfvars        # File to override default variables (e.g., credentials, region)
├── modules/
│   ├── vpc/                # Module for VPC, subnets, NAT Gateway configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security_groups/    # Module for Security Groups configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── network_acls/       # Module for Network ACLs configuration
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ec2_instance/       # Module for EC2 instance deployment (Bastion, K3s Master, K3s Agent)
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       |
│       ├── install_k3s_master.sh.tpl      # User-data script for K3s Master
│       └── install_k3s_agent.sh.tpl       # User-data script for K3s Agent
└── README.md               # This file
````
Deployment Configuration (Variables)
You can customize the cluster deployment parameters by modifying the values in the terraform.tfvars file (or by creating a terraform.dev.tfvars for your environment). Below are the key variables that affect the deployment:

### General AWS settings
- aws_region = "us-west-1" # **AWS region for deployment**

### General project metadata
- group_name = "rs.school"
- iam_user_name = "my_user_task1"
- project_name   = "rsschool"
- environment    = "dev"
- s3_bucket_name = "rsschool-bucket"
- owner = "my_user_task1"
- tags = {
Purpose = "K3s Cluster"
} # Example of common tags

````
# VPC Settings
vpc_name           = "rsschool-dev"
vpc_cidr           = "10.0.0.0/16"
azs                = ["us-west-1a", "us-west-1b"] # Availability Zones
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
enable_nat_gateway = false # Using EC2 instance as NAT Gateway
single_nat_gateway = false # Not applicable when using EC2 as NAT
````
````
# EC2 Instance Configuration
# AMI ID for Amazon Linux 2 (check for current AMI in your region)
# ami-0328fd517ab093761 - example AMI for us-west-1
````
```
bastion_nat_ami_id        = "ami-0328fd517ab093761"
bastion_nat_instance_type = "t2.micro" # Bastion/NAT instance type

private_vm_ami_id        = "ami-0328fd517ab093761"
private_vm_instance_type = "t2.micro"
private_vm_count         = 0 # Number of general purpose private VMs (0 in this task)

internal_public_vm_ami_id        = "ami-0328fd517ab093761"
internal_public_vm_instance_type = "t2.micro"
internal_public_vm_count         = 0 # Number of general purpose public VMs (0 in this task)

k3s_master_ami_id        = "ami-0328fd517ab093761"
k3s_master_instance_type = "t2.micro" # K3s Master instance type

k3s_agent_ami_id        = "ami-0328fd517ab093761"
k3s_agent_instance_type = "t2.micro" # K3s Agent instance type
agent_count             = 1 # Number of K3s agents (1 agent + 1 master = 2 nodes in the cluster)
```
### Prefix for Terraform resource naming
- name_prefix = "my-project-dev"

### SSH Key Names (must be pre-uploaded to AWS EC2)
- vm_key_name      = "vm-key"
- bastion_key_name = "bastion-key"

Cluster Deployment
Terraform Initialization
Navigate to the root of your project directory (cd your_repo_path).
Run terraform init to initialize the backend and download necessary providers/modules:

- terraform init

Planning and Application
Review the deployment plan to understand which resources will be created:

- terraform plan -var-file=terraform.dev.tfvars

If the plan looks correct, apply it to create the infrastructure:

- terraform apply -var-file=terraform.dev.tfvars

Confirm the execution by typing yes when prompted. The deployment will take several minutes.

After terraform apply completes, retrieve the output variables which will contain IP addresses and other instance information:

- terraform output
---

### CRITICALLY IMPORTANT: 
Wait for 5-7 minutes after terraform apply finishes to allow the user-data scripts on the K3s EC2 instances to fully complete their work of installing K3s and registering the nodes.

----
### Accessing the Cluster
#### Access via Bastion Host
To access the K3s Master node, 
you first need to connect to the Bastion Host,
and then from the Bastion Host to the Master.

### Connection Steps:

### Start ssh-agent:

`eval "$(ssh-agent -s)"`
#### (On Windows, use Git Bash or WSL for this command. In PowerShell, the command will be Start-SshAgent followed by ssh-add.)

Add your private keys to ssh-agent:

ssh-add ~/.ssh/bastion-key.pem # Replace with actual path to your key for Bastion
#### ssh-add ~/.ssh/vm-key.pem # If you have a separate key for K3s instances

(Replace ~/.ssh/bastion-key.pem with the actual path to your .pem file)

#### Connect to the Bastion/NAT Instance:
First, connect to the Bastion Host using its public DNS name (or public IP address) from terraform output. The -A flag (agent forwarding) is crucial as it allows you to use the same SSH key for subsequent connections from the Bastion Host to other private VMs.
```bash
ssh -A ec2-user@<Public_DNS_Name_of_Bastion_NAT_VM>
```
*  Example: ssh -A ec2-user@ec2-54-176-235-69.us-west-1.compute.amazonaws.com

(ec2-user is the default username for Amazon Linux AMIs. If you are using a different AMI, the username may vary (e.g., ubuntu, centos, admin).)
Note: We are utilizing the free DNS names provided by AWS for our EC2 instances, and NOT Elastic IPs, which incur charges under certain usage conditions.

From the Bastion Host, connect to K3s Master:
Once successfully connected to the Bastion Host, you can use it to access the K3s Master node using its private IP address from terraform output. Thanks to ssh-agent forwarding, you do not need to copy the private key to the Bastion Host.

- From the bastion host
+ ssh ec2-user@<Private_IP_of_K3s_Master>
* Example: ssh ec2-user@10.0.101.35

4. You are now on the master node and can execute kubectl commands.



### Access from Local Computer
To manage the K3s cluster directly from your local computer, you will need to create an SSH tunnel to the master node via the Bastion Host and configure your kubeconfig.

Copy the kubeconfig file from the master node to your local computer:

#### Replace IP addresses and DNS name with the actual values from terraform output.

Ensure ~/.ssh/bastion-key.pem points to your private SSH key.

scp -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/bastion-key.pem ec2-user@<Public_DNS_Name_of_Bastion_NAT_VM>" -i ~/.ssh/bastion-key.pem ec2-user@<Private_IP_of_K3s_Master>:/home/ec2-user/.kube/config ~/.kube/config_k3s_cluster
- * Example: scp -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/bastion-key.pem ec2-user@ec2-54-176-235-69.us-west-1.compute.amazonaws.com" -i ~/.ssh/bastion-key.pem ec2-user@10.0.101.35:/home/ec2-user/.kube/config ~/.kube/config_k3s_cluster 

This command will copy the kubeconfig file from the master node to ~/.kube/config_k3s_cluster on your local computer.
Important Note: The kubeconfig file generated by K3s on the master node contains server: https://127.0.0.1:6443. DO NOT CHANGE this address in the ~/.kube/config_k3s_cluster file! The SSH tunnel you create next will handle redirecting local traffic from 127.0.0.1:6443 to the master's private IP via the Bastion.

#### Open a new terminal on your local computer and create an SSH tunnel:

This tunnel will forward traffic from your local port 6443 to port 6443 of the K3s Master via the Bastion.

#### Replace IP addresses, DNS name, and key path with the actual values.

```ssh -i ~/.ssh/bastion-key.pem -L 6443:<Private_IP_of_K3s_Master>:6443 ec2-user@<Public_DNS_Name_of_Bastion_NAT_VM> -N```

##### Example: 
`ssh -i ~/.ssh/bastion-key.pem -L 6443:10.0.101.35:6443 ec2-user@ec2-54-176-235-69.us-west-1.compute.amazonaws.com -N`

Leave this terminal open while you are working with the cluster. It keeps the tunnel active.

Open another new terminal on your local computer.

In this new terminal, set the KUBECONFIG environment variable:

`export KUBECONFIG=~/.kube/config_k3s_cluster`

Verify the cluster from your local computer:

**`kubectl get nodes`**

You should see both nodes Ready.

For persistent use, you can add export KUBECONFIG=~/.kube/config_k3s_cluster to your .bashrc or .zshrc. When you are finished working with the cluster, close the terminal where you ran the ssh -L command.

Cluster Verification
After deployment and allowing time for initialization, verify the status of the cluster nodes from the Bastion Host (after connecting to the master node via Bastion, as described above):

`kubectl get nodes`
```
Expected Output:

NAME                                       STATUS   ROLES                 AGE   VERSION
ip-10-0-101-35.us-west-1.compute.internal   Ready    control-plane,master   Xm   v1.32.5+k3s1
ip-10-0-102-6.us-west-1.compute.internal    Ready    <none>                 Ym   v1.32.5+k3s1
```
(where X and Y are node uptimes)

Workload Deployment
Deploy a simple test workload (e.g., Nginx Pod) to the cluster:

`kubectl apply -f https://k8s.io/examples/pods/simple-pod.yaml`

Verify the status of all pods and other resources in the cluster:

`kubectl get all --all-namespaces`

Expected Output: In the list of pods (in the default namespace), you should see nginx in a Running status.

Resource Cleanup
To delete all AWS resources created by this Terraform code, execute:

#### `terraform destroy -var-file=terraform.dev.tfvars`

Confirm deletion by typing yes when prompted.

Troubleshooting (Key Debugging Points)
During the deployment of this cluster, the following common issues were identified and resolved:

Network Issues (Security Groups / Network ACLs): Ensure that Security Groups and Network ACLs are correctly configured to allow SSH (from Bastion), K3s API (6443/TCP between master and agents), as well as necessary inbound/outbound traffic for ephemeral ports and ICMP, especially for traffic traversing the NAT Gateway. Incorrect rules can lead to connect: connection refused or timeouts.

SELinux Conflicts: Amazon Linux 2 with SELinux enabled by default can conflict with K3s installation. This is resolved by passing INSTALL_K3S_SELINUX_DISABLE=true and INSTALL_K3S_SKIP_SELINUX_RPM=true options to the K3s installation script. These variables must be exported or included directly in the curl ... | sh - command pipeline.

K3s Token Issues ("not authorized"): If an agent cannot authenticate, it almost always means the token it's using doesn't match the master's token. The solution involves:

Automating token generation using Terraform's random_password.

Master: When installing K3s, use this generated token (passed as a variable in user_data) and ensure it's stored in AWS SSM Parameter Store (aws ssm put-parameter). The master's IAM role must have ssm:PutParameter permission.

Agent: When installing K3s, the agent must read this token from AWS SSM Parameter Store (aws ssm get-parameter). The agent's IAM role must have ssm:GetParameter permission.

kubectl: command not found: This error on the master node indicates that the K3s installation did not complete successfully, or that the symlink for kubectl was not created, or environment variables were not configured in .bashrc. Check the cloud-init-output.log on the master node for errors after [INFO] systemd: Starting k3s.

Robust user-data scripts: It's important to use set -ex in scripts for immediate exit on errors and detailed logging. Including retry mechanisms for network connectivity and SSM token retrieval (with timeouts) makes the scripts more resilient to transient issues during instance startup.

---

# task_4

## Deploying Jenkins on AWS with Helm and GitHub Actions
In this task, we deploy Jenkins, an open-source automation server,
to our K3s cluster on AWS using Helm for package management
and GitHub Actions to automate the deployment process.

Task Objectives
Install and verify Helm.

Ensure the cluster has a solution for managing persistent volumes (PVs) and persistent volume claims (PVCs) (using local-path-provisioner in K3s).

Install Jenkins using Helm in a separate namespace.

Ensure Jenkins is accessible via a web browser.

Configure Jenkins to store its configuration on a persistent volume.

Create a simple Jenkins "Hello world" project that runs successfully and outputs "Hello world" to the log.

Set up a GitHub Actions pipeline to deploy Jenkins.

Configure authentication and security settings for Jenkins (initial admin password).

Use Jenkins Configuration as Code (JCasC) to define the "Hello World" job.

## Stack
- Kubernetes (K3s)

- Helm v3+

- Jenkins LTS

- Jenkins Configuration as Code (JCasC)

- GitHub Actions

- AWS EC2, VPC, S3, SSM (as part of the base infrastructure)

 Jenkins Configuration (Helm values.yaml)
Jenkins configuration for Helm deployment is defined in the jenkins/values.yaml file. This file includes:

NodePort Service Type: Jenkins is accessible via a NodePort on the K3s master node.

Persistent Storage: Enabled to preserve Jenkins data (jobs, plugins, configuration) across pod restarts. storageClass: "local-path" is used, which is provided by K3s by default.

Jenkins Configuration as Code (JCasC): Used for declarative definition of Jenkins configuration, including job creation.

Example jenkins/values.yaml:

controller:
  image:
    registry: docker.io
    repository: jenkins/jenkins
    tag: lts

  serviceType: NodePort
  nodePort: 32005 # Or any other NodePort from the 30000-32767 range

  persistence:
    enabled: true
    storageClass: "local-path"
    accessMode: ReadWriteOnce
    size: 5Gi
```yaml
  JCasC:
    enabled: true
    configScripts:
      my-jcasc: |
        jenkins:
          # Other global Jenkins settings can go here
          # systemMessage: "Configured via JCasC" # May cause conflicts if already defined by Helm chart
        jobs: # Important: jobs: must be at the same indentation level as jenkins:
          - script: >
              pipelineJob('hello-world') {
                definition {
                  cps {
                    script('''node { echo "Hello world" }''')
                  }
                }
              }
        # Other JCasC sections (security, clouds, tool, etc.) should also be here
        # at the same indentation level as jenkins: and jobs:.
        # They might be automatically added by the Helm chart, but if you want to override them,
        # add them here.
```
 GitHub Actions Pipeline for Jenkins Deployment
File: **`.github/workflows/jenkins-deploy.yml`**

This pipeline automates the process of deploying Jenkins to the K3s cluster:

Trigger: Runs after the successful completion of the terraform-deploy.yml pipeline with a 40-second delay to allow infrastructure to stabilize. It can also be triggered manually or by a push to specific branches.

AWS Authentication: Configures AWS credentials using OIDC for access to the SSM Parameter Store.

Fetch kubeconfig: Retrieves the kubeconfig file from AWS SSM Parameter Store, which is necessary for interacting with the Kubernetes cluster.

Tool Installation: Installs kubectl and helm in the GitHub Actions runner environment.

Helm Verification: Includes steps to add the Bitnami repository and deploy/delete the Nginx chart to verify the Helm installation's functionality.

Wait for Kubernetes API Server: Waits until the Kubernetes API server is available.

Deploy/Upgrade Jenkins: Uses helm upgrade --install to deploy or update Jenkins in the jenkins namespace, applying settings from jenkins/values.yaml.

Verify Jenkins Deployment: Checks the deployment status of the Jenkins StatefulSet.

Self-hosted Runner: Note that the pipeline runs on a self-hosted runner deployed in your VPC (on an EC2 instance), which provides access to internal AWS resources.

### 🌐 Accessing Jenkins
To access the Jenkins web interface, deployed in a private subnet, you need to create an SSH tunnel through the Bastion Host.

### Create SSH Tunnel:
Use the following command on your local machine.
Replace <PUBLIC_DNS_OF_BASTION> with the public DNS of your Bastion Host,
and <PRIVATE_IP_OF_K3S_MASTER> with the private IP of your K3s master node.
```Bash
ssh -i ~/.ssh/bastion-key.pem \
  -J ec2-user@<PUBLIC_DNS_OF_BASTION> \
  -i ~/.ssh/vm-key.pem \
  -L 8080:<PRIVATE_IP_OF_K3S_MASTER>:32005 \
  ec2-user@<PRIVATE_IP_OF_K3S_MASTER> -N
```
Keep this terminal open while you are working with Jenkins.

Get Initial Admin Password:
After successful Jenkins deployment, retrieve the initial admin password by executing the following command on the K3s master node (after connecting via SSH):
``
kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode && echo
``
Access via Browser:
Open a web browser and navigate to http://localhost:8080. Use the retrieved password and username admin to log in.

 Connecting Jenkins to Kubernetes (Service Account)
Jenkins, deployed in Kubernetes, uses a Service Account to interact with the Kubernetes API. This allows Jenkins to dynamically create agent pods for executing tasks. The Jenkins Helm chart automatically creates the necessary jenkins Service Account in the jenkins namespace and binds the required permissions to it (via RoleBinding/ClusterRoleBinding) so that Jenkins can manage pods in the cluster.

 Verification & Submission

✅ Helm is installed and verified by deploying and removing the Nginx chart (automated in the jenkins-deploy.yml pipeline).

✅ Jenkins is installed using Helm in a separate namespace (jenkins).

✅ Jenkins is accessible from the web browser (after creating an SSH tunnel via Bastion).

✅ Jenkins configuration is persisted on a persistent volume (verified by restarting the Jenkins pod).

✅ A simple Jenkins "Hello world" project is created and runs successfully, outputting "Hello world" to the log. (Initially created manually, but the goal is via JCasC).

✅ A GitHub Actions pipeline is set up to deploy Jenkins.

✅ Authentication and security settings are configured for Jenkins (initial admin password).

✅ JCasC is used to describe the "Hello World" job.

Screenshots for PR:

Screenshot of the Jenkins freestyle project log showing "Hello world".

Screenshot of kubectl get all --all-namespaces (executed on the K3s Master node or via local kubectl with a tunnel).

PR:

<<<<<<< Updated upstream
PR from task_4 branch to main including all code and outputs
=======
PR from task_4 branch to main including all code and outputs

----

# task_5

## 📦 Flask App  Helm Chart

### 📋 Description

**Task_5** demonstrates the deployment of a simple Flask web application in a Kubernetes cluster using Docker and Helm. The application displays the message **"Hello, Flask!"**.

The process includes:

- Creating a Flask application.
- Containerizing the application with Docker (the image is public).
- Creating a Helm chart for declarative deployment management in Kubernetes.
- Automating the deployment process using GitHub Actions.
- Making the application accessible via a web browser.

## ⚙️ Project Structure

```
rolling-scopes-school/
├── flask-app/
│ ├── Chart.yaml # Helm chart metadata
│ ├── values.yaml # Helm chart settings (image, ports, replicas)
│ ├── templates/ # Kubernetes manifest templates
│ │ ├── deployment.yaml # Deployment definition for the app
│ │ ├── service.yaml # Service (NodePort) definition for access
│ │ └── _helpers.tpl # Helm helper templates
│ ├── main.py # Flask app code
│ ├── requirements.txt # Python dependencies
│ └── Dockerfile # Docker image definition
├── .github/workflows/
│ └── flask-app-deploy.yml # GitHub Actions pipeline for Flask App deployment
└── ... (other repository files)
```

## 🐳 Docker Image

The application is containerized in a Docker image.

- **Dockerfile:**

    ```dockerfile
    FROM python:3.9-slim  

    WORKDIR /app  

    COPY requirements.txt .  
    RUN pip install --no-cache-dir -r requirements.txt  

    COPY main.py .  

    ENV FLASK_APP=main.py  

    CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"]
    ```

- **Public image repository:** `igor237/my-flask-app:latest`  
  Since the image is public, it does not require authentication for pulling.

## 🧩 Helm Chart

The `flask-app` Helm chart is used to deploy the application in Kubernetes.

- **`values.yaml`  key settings:**

    ```yaml
    replicaCount: 1

    image:
      repository: igor237/my-flask-app
      tag: latest
      pullPolicy: Always

    service:
      type: NodePort
      port: 80
      targetPort: 8080 # Port the Flask app listens on inside the container
      nodePort: 30081  # Explicit NodePort for external access

    # Note: 'containerPort: 8080' should not be set here in values.yaml.
    # It must be defined in templates/deployment.yaml.
    ```

  - **`templates/deployment.yaml`**: Creates a Kubernetes `Deployment` managing the pods with the app. Configured to use the `igor237/my-flask-app:latest` image and expose port `8080` inside the container (`containerPort: 8080` should be defined here).

  - **`templates/service.yaml`**: Creates a Kubernetes `Service` of type `NodePort` to expose the pods. It forwards traffic from port `80` of the service to port `8080` of the container. The explicit `NodePort` `30081` allows access from outside the cluster.

## 🚀 Deploying the Application

Deployment is automated using GitHub Actions.

### **Prerequisites for CI/CD Runner:** (task_4)

For the pipeline to work on a self-hosted runner, the following must be installed and configured:

- **AWS CLI:** To retrieve `kubeconfig` from the SSM Parameter Store.
- **`kubectl`:** To interact with the Kubernetes cluster.
- **Helm:** To deploy the Helm chart.
- **Configured AWS Credentials:** For authentication in AWS (via OIDC and IAM Role).
- **Kubeconfig in AWS SSM Parameter Store:** Path `/my-project-dev/kubeconfig`.

### **GitHub Actions Pipeline (`.github/workflows/flask-app-deploy.yml`):**

## 🌐 Application Access

After successful deployment, the application will be available via the public IP address of any of your K3s nodes (master or agent) on the NodePort `30081`.

### **Access via SSH Tunnel:**

If direct access to the NodePort is restricted or you prefer tunneling, you can create an SSH tunnel through a Bastion Host.

- **Create an SSH tunnel:** Use the following command on your local machine. Replace `<PUBLIC_DNS_OF_BASTION>` with your Bastion Host’s public DNS, and `<PRIVATE_IP_OF_K3S_MASTER>` with the private IP of your K3s master node.

    ```bash
    ssh -i ~/.ssh/bastion-key.pem \
      -J ec2-user@<PUBLIC_DNS_OF_BASTION> \
      -i ~/.ssh/vm-key.pem \
      -L 8080:<PRIVATE_IP_OF_K3S_MASTER>:30081 \
      ec2-user@<PRIVATE_IP_OF_K3S_MASTER> -N
    ```

###    Keep this terminal open while working with the app.

- **Open the app in a browser:** Once the tunnel is established, open your web browser and go to: `http://localhost:8080`

  You should see the message: **"Hello, Flask!"**
---
# task_6
>>>>>>> Stashed changes

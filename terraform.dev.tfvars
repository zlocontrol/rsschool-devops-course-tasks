

aws_region = "us-west-1"

group_name    = "rs.school"
iam_user_name = "my_user_task1"

project_name   = "rsschool"
environment    = "dev"
s3_bucket_name = "rsschool-bucket"
owner          = "my_user_task1"

vpc_name           = "rsschool-dev"
vpc_cidr           = "10.0.0.0/16"
azs                = ["us-west-1a", "us-west-1b"]
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
enable_nat_gateway = false # Using EC2 instance as NAT
single_nat_gateway = false



# Bastion-NAT VM
bastion_nat_ami_id        = "ami-0328fd517ab093761"
bastion_nat_instance_type = "t2.micro"

# General Purpose Private VMs
private_vm_ami_id        = "ami-0328fd517ab093761"
private_vm_instance_type = "t2.micro"
private_vm_count         = 0 # Create * shared private VM

# Internal Public VM (VM-PUBLIC)
internal_public_vm_ami_id        = "ami-0328fd517ab093761"
internal_public_vm_instance_type = "t2.micro"
internal_public_vm_count         = 0 # Create * public VM

# K3s Master Node
k3s_master_ami_id        = "ami-0328fd517ab093761"
k3s_master_instance_type = "t2.micro"

# K3s Agent Nodes
k3s_agent_ami_id        = "ami-0328fd517ab093761"
k3s_agent_instance_type = "t2.micro"
agent_count             = 1 # Create 1 K3s agent (only 2 nodes with master)

name_prefix = "my-project-dev"

vm_key_name      = "vm-key"
bastion_key_name = "bastion-key"
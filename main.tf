

provider "aws" {
  region = var.aws_region
}


module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  # name      = var.project_name
  # namespace = var.environment
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name            = var.vpc_name
  cidr            = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = local.common_tags
}

module "security_groups" {
  source      = "./modules/security_groups"
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = module.vpc.vpc_cidr_block
  common_tags = local.common_tags
}

module "network_acls" {
  source = "./modules/network_acls"

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
  vpc_cidr           = module.vpc.vpc_cidr_block
  name_prefix        = module.label.id
  common_tags        = local.common_tags
}

module "compute" {
  source = "./modules/ec2_instance"

  # --- Granular EC2 AMI and Instance Type variables ---
  bastion_nat_ami_id        = var.bastion_nat_ami_id
  bastion_nat_instance_type = var.bastion_nat_instance_type

  private_vm_ami_id        = var.private_vm_ami_id
  private_vm_instance_type = var.private_vm_instance_type
  private_vm_count         = var.private_vm_count

  internal_public_vm_ami_id        = var.internal_public_vm_ami_id
  internal_public_vm_instance_type = var.internal_public_vm_instance_type
  internal_public_vm_count         = var.internal_public_vm_count

  k3s_master_ami_id        = var.k3s_master_ami_id
  k3s_master_instance_type = var.k3s_master_instance_type

  k3s_agent_ami_id        = var.k3s_agent_ami_id
  k3s_agent_instance_type = var.k3s_agent_instance_type
  agent_count             = var.agent_count
  k3s_token               = random_password.k3s_token_generator.result

  # --- Other variables (subnets, SGs, keys, routing) ---
  bastion_nat_subnet_id        = module.vpc.public_subnets[0]
  internal_public_vm_subnet_id = module.vpc.public_subnets[1]
  private_subnet_ids           = module.vpc.private_subnets

  bastion_nat_sg_id        = module.security_groups.bastion_nat_sg_id
  private_vm_sg_id         = module.security_groups.private_vm_sg_id
  internal_public_vm_sg_id = module.security_groups.internal_public_vm_sg_id


  # Passing Private Routing Table ID to Configure NAT Instance
  private_route_table_ids = module.vpc.private_route_table_ids





  bastion_nat_key_name = var.bastion_key_name
  vm_key_name          = var.vm_key_name

  # --- K3s IAM/SSM specific variables ---
  k3s_ec2_profile_name = aws_iam_instance_profile.k3s_ec2_profile.name
  k3s_token_ssm_path   = aws_ssm_parameter.k3s_token_parameter.name
  aws_region           = var.aws_region

  # --- Naming and Tags ---
  name_prefix               = module.label.id
  tags                      = merge(local.common_tags, { task = "2" })
  private_subnet_attributes = {}


  # --- NEW: GitHub Actions Runner ---
  gha_runner_ami_id        = var.gha_runner_ami_id
  gha_runner_instance_type = var.gha_runner_instance_type


  github_url   = var.github_url
  repo_name    = var.repo_name
  runner_token = var.runner_token
  repo_owner   = var.repo_owner
}
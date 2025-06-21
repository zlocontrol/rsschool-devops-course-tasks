

provider "aws" {
  region = var.aws_region
}



module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = var.azs
  public_subnets       = var.public_subnets
  private_subnets      = var.private_subnets


  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

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
  # USING module.vpc.public_subnets
  public_subnet_ids  = module.vpc.public_subnets
  # USING module.vpc.private_subnets
  private_subnet_ids = module.vpc.private_subnets
  vpc_cidr           = module.vpc.vpc_cidr_block
  name_prefix        = module.label.id
  common_tags        = local.common_tags
}



module "compute" {
  source = "./modules/ec2_instance"

  ami_id            = var.ami_id
  instance_type     = var.instance_type
  private_vm_count  = var.instance_count # Pass instance_count as private_vm_count

  # Transferring Subnet IDs
  bastion_nat_subnet_id        = module.vpc.public_subnets[0]
  internal_public_vm_subnet_id = module.vpc.public_subnets[1]
  private_subnet_ids           = module.vpc.private_subnets

  # Passing Security Groups IDs from the new "security_groups" module
  bastion_nat_sg_id            = module.security_groups.bastion_nat_sg_id
  private_vm_sg_id             = module.security_groups.private_vm_sg_id
  internal_public_vm_sg_id     = module.security_groups.internal_public_vm_sg_id

  # Passing Private Routing Table ID to Configure NAT Instance
  private_route_table_ids      = module.vpc.private_route_table_ids

  # SSH Key Names
  bastion_nat_key_name         = var.bastion_key_name
  vm_key_name                  = var.vm_key_name

  name_prefix = "vm"
  tags        = merge(local.common_tags, { task = "2" })
}
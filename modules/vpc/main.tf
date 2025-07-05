module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "`> 5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true


  manage_default_route_table    = false
  manage_default_network_acl    = false
  manage_default_security_group = false
  create_igw                    = true

  tags = var.tags
}

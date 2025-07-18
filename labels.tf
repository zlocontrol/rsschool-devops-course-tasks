# ===========================
# labels.tf
# ===========================
#
# # module "labels_rds" {
# #   source  = "cloudposse/label/null"
# #   version = "0.25.0"
#
#
#
# }

module "labels_vpc" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name      = "vpc"
  namespace = "rsschool"
  stage     = "dev"
  tags      = merge(local.common_tags, { task = "2" })
}

module "labels_bastion" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name      = "bastion"
  namespace = "rsschool"
  stage     = "dev"
  tags      = merge(local.common_tags, { task = "2" })
}

module "label_K3s" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace  = var.project_name
  name       = var.environment
  attributes = ["k3s"]
  tags       = merge(local.common_tags, { task = "3" })
}

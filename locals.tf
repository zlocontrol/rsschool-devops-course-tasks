# locals {
#   common_tags = {
#     Environment = var.environment
#     Project     = var.project_name
#     Owner       = var.owner
#     ManagedBy   = "terraform"
#   }
# }

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Owner       = var.owner
    task        = "2"
  }
}
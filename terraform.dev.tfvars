aws_region = "us-west-1"

#group_name
group_name = "rs.school"

#name_user
iam_user_name = "my_user_task1"

project_name   = "rsschool"
environment    = "dev"
s3_bucket_name = "rsschool-bucket"





owner = "my_user_task1"

########
###VPC##
########
vpc_name           = "rsschool-dev"
vpc_cidr           = "10.0.0.0/16"
azs                = ["us-west-1a", "us-west-1b"]
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
enable_nat_gateway = false
single_nat_gateway = false



ami_id = "ami-0328fd517ab093761"

name_prefix = "vm"




security_group_id = "REPLACE_ME"



vm_key_name      = "vm-key"
bastion_key_name = "bastion-key"
###################
#####  EC_2
###################
######## private vm & public
instance_count = 2

instance_type = "t2.micro"


create_nat_instance = true

nat_instance_type = "t2.micro"
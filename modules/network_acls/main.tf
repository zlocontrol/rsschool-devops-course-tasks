
# Network ACL for public subnets
resource "aws_network_acl" "public_nacl" {
  vpc_id = var.vpc_id
  # Subnet Association
  subnet_ids = var.public_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-nacl"
  })
}

# Incoming Rules for Public NACL
# description    = "Allow SSH from Internet to Public Subnets (Bastion)"
resource "aws_network_acl_rule" "public_nacl_ingress_ssh_bastion" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  from_port      = 22
  to_port        = 22
  cidr_block     = "0.0.0.0/0"
  rule_action    = "allow"

}


# Allowing incoming ICMP Echo Requests
resource "aws_network_acl_rule" "public_nacl_ingress_icmp_echo_request" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 115
  egress         = false
  protocol       = "icmp"
  icmp_type      = 8           # Тип ICMP для Echo Request
  icmp_code      = 0           # Код ICMP для Echo Request
  cidr_block     = "0.0.0.0/0" # Allow Echo Request from any source (including VPC)
  rule_action    = "allow"

}





# Allow Incoming ICMP
resource "aws_network_acl_rule" "public_nacl_ingress_icmp" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 120 #
  egress         = false
  protocol       = "icmp"

  cidr_block  = "0.0.0.0/0"
  rule_action = "allow"

}





# Rule for HTTP/HTTPS (if you have web servers in public subnets like internal_public_vm for web hosting)
#

resource "aws_network_acl_rule" "public_nacl_ingress_http" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 112
  egress         = false
  protocol       = "tcp"
  from_port      = 80
  to_port        = 80
  cidr_block     = "0.0.0.0/0"
  rule_action    = "allow"
  # description    = "Allow HTTP from Internet"
}

resource "aws_network_acl_rule" "public_nacl_ingress_https" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 113
  egress         = false
  protocol       = "tcp"
  from_port      = 443
  to_port        = 443
  cidr_block     = "0.0.0.0/0"
  rule_action    = "allow"
  # description    = "Allow HTTPS from Internet"
}



resource "aws_network_acl_rule" "public_nacl_ingress_ephemeral" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 130
  egress         = false
  protocol       = "tcp"
  from_port      = 1024
  to_port        = 65535
  cidr_block     = "0.0.0.0/0"
  rule_action    = "allow"

}

# Outbound rules for public NACL (allow all outbound traffic)
resource "aws_network_acl_rule" "public_nacl_egress_all" {
  network_acl_id = aws_network_acl.public_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1" # All traffic
  cidr_block     = "0.0.0.0/0"
  rule_action    = "allow"

}


# Network ACL for private subnets
resource "aws_network_acl" "private_nacl" {
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids # Ассоциируем с приватными подсетями

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-nacl"
  })
}

# Inbound rules for private NACL
#description    = "Allow all inbound traffic from VPC"
resource "aws_network_acl_rule" "private_nacl_ingress_vpc" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  cidr_block     = var.vpc_cidr
  rule_action    = "allow"

}

# description    = "Allow inbound ephemeral ports from Internet (via NAT)"
resource "aws_network_acl_rule" "private_nacl_ingress_ephemeral" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  from_port      = 1024
  to_port        = 65535
  cidr_block     = "0.0.0.0/0" # Where do the answers come from (from the Internet)
  rule_action    = "allow"

}

# description    = "Allow all outbound traffic to Internet (via NAT)"
resource "aws_network_acl_rule" "private_nacl_egress_all" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1" # All traffic
  cidr_block     = "0.0.0.0/0"
  rule_action    = "allow"

}


# Allow Incoming ICMP for Private NACL
resource "aws_network_acl_rule" "private_nacl_ingress_icmp" {
  network_acl_id = aws_network_acl.private_nacl.id
  rule_number    = 105 # Или любое число между 100 и 110
  egress         = false
  protocol       = "icmp"
  cidr_block     = "0.0.0.0/0" # Allow ICMP responses from any external sources (after NAT)
  rule_action    = "allow"

}

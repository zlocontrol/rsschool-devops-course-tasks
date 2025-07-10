

# Security Group for VM-Bastion (which is also the NAT Instance)
resource "aws_security_group" "bastion_nat_sg" {
  name        = "bastion-nat-sg-${var.common_tags.Environment}"
  description = "Allow SSH from internet for Bastion and traffic for NAT functionality"
  vpc_id      = var.vpc_id

  # Ingress: Allow SSH from internet (for Bastion access)
  ingress {
    description = "SSH from anywhere to Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress: Allow all traffic from VPC CIDR (for NAT requests from private VMs)
  ingress {
    description = "Allow all traffic from VPC CIDR (for NAT function)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] # Разрешаем входящий трафик из всей VPC
  }

  # Egress: Allow all outbound traffic to internet (for Bastion & NAT)
  egress {
    description = "Allow all outbound traffic to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "bastion-nat-sg" })
}

# Security Group for Private VMs (VM-1, VM-2)
resource "aws_security_group" "private_vm_sg" {
  name        = "private-vm-sg-${var.common_tags.Environment}"
  description = "Allow SSH from Bastion-NAT and outbound internet access via NAT"
  vpc_id      = var.vpc_id

  # Ingress rule: Allow SSH from Bastion-NAT SG
  ingress {
    description     = "SSH from Bastion-NAT Host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_nat_sg.id] # Разрешаем SSH только с объединенного Bastion/NAT
  }
  # aws_security_group "internal_public_vm_sg"
  ingress {
    description = "Allow K3s API server port from VPC"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  # Egress rule: Allow all outbound traffic (routed via Bastion-NAT)
  egress {
    description = "Allow all outbound traffic to internet (via NAT)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "private-vm-sg" })
}

# Security Group for VM-PUBLIC (Internal Public VM)
resource "aws_security_group" "internal_public_vm_sg" {
  name        = "internal-public-vm-sg-${var.common_tags.Environment}"
  description = "Allow SSH from Bastion-NAT; no direct internet access"
  vpc_id      = var.vpc_id

  # Ingress: Allow SSH from Bastion-NAT Host
  ingress {
    description     = "SSH from Bastion-NAT Host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_nat_sg.id]
  }


  # Ingress: Allow all traffic from VPC CIDR (if other internal services need to reach it)
  ingress {
    description = "Allow all traffic from VPC CIDR"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # Egress: Allow outbound traffic ONLY within VPC (no internet egress)
  egress {
    description = "Allow all outbound traffic within VPC only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "internal-public-vm-sg" })
}

resource "aws_security_group_rule" "allow_nodeport_range" {
  description       = "Allow all Kubernetes NodePorts"
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  security_group_id = aws_security_group.private_vm_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

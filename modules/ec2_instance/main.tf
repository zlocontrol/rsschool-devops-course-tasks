

# ----------------------------------------------------
# 1. Bastion Host (combined Bastion-NAT Instance)
# ----------------------------------------------------
resource "aws_instance" "bastion_nat_vm" {
  ami                         = var.bastion_nat_ami_id        # Use specific AMI
  instance_type               = var.bastion_nat_instance_type # Use specific instance type
  subnet_id                   = var.bastion_nat_subnet_id
  vpc_security_group_ids      = [var.bastion_nat_sg_id]
  key_name                    = var.bastion_nat_key_name
  associate_public_ip_address = true
  source_dest_check           = false

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y iptables-services -y
    sudo systemctl enable iptables
    sudo systemctl start iptables
    sudo sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
    sudo iptables -F FORWARD
    sudo iptables -P FORWARD DROP
    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    sudo iptables -A FORWARD -i eth0 -s 10.0.0.0/16 -o eth0 -j ACCEPT
    sudo iptables-save | sudo tee /etc/sysconfig/iptables
    sudo systemctl enable --now iptables
    EOF

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-bastion-nat"
  })
}

# ----------------------------------------------------
# 2. General Purpose Private VMs
# ----------------------------------------------------
resource "aws_instance" "private_vm" {
  count                       = var.private_vm_count
  ami                         = var.private_vm_ami_id        # Use specific AMI
  instance_type               = var.private_vm_instance_type # Use specific instance type
  subnet_id                   = element(var.private_subnet_ids, count.index % length(var.private_subnet_ids))
  vpc_security_group_ids      = [var.private_vm_sg_id]
  key_name                    = var.vm_key_name
  associate_public_ip_address = false

  tags = merge(var.tags, {
    Name = format("%s-private-vm-%s", var.name_prefix, count.index + 1)
  })
}

# ----------------------------------------------------
# 3. Internal Public VM (VM-PUBLIC)
# ----------------------------------------------------
resource "aws_instance" "internal_public_vm" {
  count                       = var.internal_public_vm_count         # Use specific count
  ami                         = var.internal_public_vm_ami_id        # Use specific AMI
  instance_type               = var.internal_public_vm_instance_type # Use specific instance type
  subnet_id                   = var.internal_public_vm_subnet_id
  vpc_security_group_ids      = [var.internal_public_vm_sg_id]
  key_name                    = var.vm_key_name
  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = format("%s-public-vm-%s", var.name_prefix, count.index + 1)
  })
}

# ----------------------------------------------------
# 4. K3s Master Node (Server)
# ----------------------------------------------------
resource "aws_instance" "k3s_master" {
  # Master is always 1, so no count variable needed for it.
  ami                         = var.k3s_master_ami_id        # Use specific AMI
  instance_type               = var.k3s_master_instance_type # Use specific instance type
  subnet_id                   = var.private_subnet_ids[0]
  vpc_security_group_ids      = [var.private_vm_sg_id]
  key_name                    = var.vm_key_name
  associate_public_ip_address = false
  iam_instance_profile        = var.k3s_ec2_profile_name

  user_data = templatefile("${path.module}/install_k3s_master.sh.tpl", {
    aws_region = var.aws_region,

    TIMEOUT_NETWORK_SECONDS    = 300, # Пример: 5 минут
    TIMEOUT_CURL_SECONDS       = 60,
    TIMEOUT_K3S_CONFIG_SECONDS = 300 # Пример: 5 минут
    k3s_token                  = var.k3s_token
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-k3s-master"
    Role = "k3s-master"
  })
}

# ----------------------------------------------------
# 5. K3s Agent Nodes (Workers)
# ----------------------------------------------------
resource "aws_instance" "k3s_agents" {
  count                       = var.agent_count
  ami                         = var.k3s_agent_ami_id        # Use specific AMI
  instance_type               = var.k3s_agent_instance_type # Use specific instance type
  subnet_id                   = element(var.private_subnet_ids, count.index + 1)
  vpc_security_group_ids      = [var.private_vm_sg_id]
  key_name                    = var.vm_key_name
  associate_public_ip_address = false
  iam_instance_profile        = var.k3s_ec2_profile_name

  user_data = templatefile("${path.module}/install_k3s_agent.sh.tpl", {
    master_private_ip  = aws_instance.k3s_master.private_ip,
    k3s_token_ssm_path = var.k3s_token_ssm_path,
    aws_region         = var.aws_region,

    TIMEOUT_NETWORK_SECONDS   = 300,
    TIMEOUT_CURL_SECONDS      = 60,
    TIMEOUT_SSM_TOKEN_SECONDS = 180
  })

  depends_on = [
    aws_instance.k3s_master,
    # Implicit dependency on aws_ssm_parameter.k3s_token_parameter via var.k3s_token_ssm_path
  ]

  tags = merge(var.tags, {
    Name = format("%s-k3s-agent-%s", var.name_prefix, count.index + 1)
    Role = "k3s-agent"
  })
}


# 4.  NAT Instance
resource "aws_route" "nat_instance_route" {

  count = length(var.private_route_table_ids)

  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.bastion_nat_vm.primary_network_interface_id

  depends_on = [
    aws_instance.bastion_nat_vm
  ]
}
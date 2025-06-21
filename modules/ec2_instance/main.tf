

# 1.  VM-Bastion (combined Bastion-NAT Instance)

resource "aws_instance" "bastion_nat_vm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.bastion_nat_subnet_id
  vpc_security_group_ids      = [var.bastion_nat_sg_id]
  key_name                    = var.bastion_nat_key_name
  associate_public_ip_address = true
  source_dest_check           = false

  # User data for setting up NAT (Amazon Linux)

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y iptables-services -y
    sudo systemctl enable iptables
    sudo systemctl start iptables


    sudo sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf


    sudo iptables -F FORWARD
    # sudo iptables -X FORWARD #


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

# 2. Private VMs (VM-1, VM-2)

resource "aws_instance" "private_vm" {
  count                       = var.private_vm_count # Number of private VMs from the private_vm_count variable
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element(var.private_subnet_ids, count.index % length(var.private_subnet_ids))
  vpc_security_group_ids      = [var.private_vm_sg_id]
  key_name                    = var.vm_key_name
  associate_public_ip_address = false

  tags = merge(var.tags, {
    Name = format("%s-private-vm-%s", var.name_prefix, count.index + 1)
  })
}

# 3. Internal Public VM (VM-PUBLIC)

resource "aws_instance" "internal_public_vm" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.internal_public_vm_subnet_id
  vpc_security_group_ids      = [var.internal_public_vm_sg_id]
  key_name                    = var.vm_key_name
  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = format("%s-public-vm", var.name_prefix)
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
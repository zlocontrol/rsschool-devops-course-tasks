

output "bastion_nat_sg_id" {
  description = "The ID of the Bastion-NAT Security Group"
  value       = aws_security_group.bastion_nat_sg.id
}

output "private_vm_sg_id" {
  description = "The ID of the Private VM Security Group"
  value       = aws_security_group.private_vm_sg.id
}

output "internal_public_vm_sg_id" {
  description = "The ID of the Internal Public VM Security Group"
  value       = aws_security_group.internal_public_vm_sg.id
}
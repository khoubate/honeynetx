output "public_ip" {
  description = "Public IP address of the honeypot VM"
  value       = azurerm_public_ip.honeynetx-vm-ip.ip_address
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.honeynetx-vm-ip.ip_address}"
}

output "web_interface" {
  description = "URL for the T-Pot web interface"
  value       = "https://${azurerm_public_ip.honeynetx-vm-ip.ip_address}:64297"
}
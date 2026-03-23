# Cato App Connector Outputs
output "app_connector_id" {
  description = "The ID of the Cato App Connector"
  value       = cato_app_connector.this.id
}

output "app_connector_name" {
  description = "The name of the Cato App Connector"
  value       = cato_app_connector.this.name
}

output "app_connector_serial_number" {
  description = "The serial number of the Cato App Connector"
  value       = cato_app_connector.this.serial_number
}

output "app_connector_socket_id" {
  description = "The socket ID of the Cato App Connector"
  value       = cato_app_connector.this.socket_id
}

output "app_connector_description" {
  description = "The description of the Cato App Connector"
  value       = cato_app_connector.this.description
}

output "app_connector_group_name" {
  description = "The group name of the Cato App Connector"
  value       = cato_app_connector.this.group_name
}

# AWS Instance Outputs
output "instance_id" {
  description = "The ID of the App Connector EC2 instance"
  value       = aws_instance.app_connector.id
}

output "instance_arn" {
  description = "The ARN of the App Connector EC2 instance"
  value       = aws_instance.app_connector.arn
}

output "instance_private_ip" {
  description = "The private IP address of the App Connector EC2 instance"
  value       = aws_instance.app_connector.private_ip
}

output "instance_public_ip" {
  description = "The public IP address of the App Connector EC2 instance"
  value       = aws_instance.app_connector.public_ip
}

output "instance_availability_zone" {
  description = "The availability zone of the App Connector EC2 instance"
  value       = aws_instance.app_connector.availability_zone
}

output "instance_state" {
  description = "The state of the App Connector EC2 instance"
  value       = aws_instance.app_connector.instance_state
}

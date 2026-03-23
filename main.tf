## AppConnector Instance
resource "aws_instance" "app_connector" {
  tenancy          = "default"
  ami              = data.aws_ami.appConnector.id
  key_name         = var.ssh_key_pair_name
  instance_type    = var.instance_type
  user_data_base64 = base64encode(cato_app_connector.this.serial_number)
  primary_network_interface {
    network_interface_id = var.lan_eni_id
  }
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.ebs_disk_size
    volume_type = var.ebs_disk_type
  }
  tags = merge(var.tags, {
    Name = "${var.app_connector_name}-App-Connector"
  })
}

resource "aws_network_interface_attachment" "mgmt" {
  instance_id          = aws_instance.app_connector.id
  network_interface_id = var.mgmt_eni_id
  device_index         = 1
}

resource "aws_network_interface_attachment" "wan" {
  instance_id          = aws_instance.app_connector.id
  network_interface_id = var.wan_eni_id
  device_index         = 2
}

# AppConnector resource in the Cato Management Application
resource "cato_app_connector" "this" {
  name        = var.app_connector_name
  description = var.app_connector_description
  group_name  = var.app_connector_group

  location = {
    address      = var.app_connector_address
    city_name    = var.app_connector_city
    country_code = var.app_connector_country_code
    state_code   = var.app_connector_state_code
    timezone     = var.app_connector_timezone
  }
  preferred_pop_location = {
    automatic      = var.app_connector_pop_location_automatic
    preferred_only = var.app_connector_pop_location_preferred_only
    primary        = var.app_connector_primary_pop != null ? { name = var.app_connector_primary_pop } : null
    secondary      = var.app_connector_secondary_pop != null ? { name = var.app_connector_secondary_pop } : null
  }
  type = "VIRTUAL"
}


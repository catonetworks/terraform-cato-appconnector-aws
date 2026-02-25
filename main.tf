resource "cato_app_connector" "app_conn" {
  description = var.app_conn_description
  group_name  = var.app_conn_group_name
  location    = local.cur_app_conn_location
  name        = var.app_conn_name
  preferred_pop_location = {
    automatic      = var.preferred_pop_location_automatic
    preferred_only = var.preferred_pop_location_preferred_only
    primary        = var.preferred_pop_location_primary != null ? { name = var.preferred_pop_location_primary } : null
    secondary      = var.preferred_pop_location_secondary != null ? { name = var.preferred_pop_location_secondary } : null
  }
  type = "VIRTUAL"
}

## vSocket Instance
resource "aws_instance" "appcon" {
  tenancy          = "default"
  ami              = data.aws_ami.vSocket.id
  key_name         = var.key_pair
  instance_type    = var.instance_type
  user_data_base64 = base64encode(cato_app_connector.app_conn.serial_number)
  # Network Interfaces
  # MGMTENI
  network_interface {
    device_index         = 1
    network_interface_id = var.mgmt_eni_id
  }
  # WANENI
  network_interface {
    device_index         = 0
    network_interface_id = var.wan_eni_id
  }
  # LANENI
  network_interface {
    device_index         = 2
    network_interface_id = var.lan_eni_id
  }
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.ebs_disk_size
    volume_type = var.ebs_disk_type
  }
  tags = merge(var.tags, {
    Name = "${var.app_conn_name}-App-Connector"
  })
}

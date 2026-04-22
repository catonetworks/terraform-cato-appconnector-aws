# CATO APP CONNECTOR AWS Terraform module

Terraform module which creates an AWS App Connector in the Cato Management Application (CMA), and deploys a virtual app connector ec2 instance in AWS used to connect private applications over the Cato network.

- *Note: This feature is currently in Early Availability (EA) and has been rolled out to a limited set of customer accounts for testing and validation purposes.*

## Usage
<details>
<summary>Configure the providers</summary>

```hcl
// Initialize Providers
provider "aws" {
  region = var.region
}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}
```
</details>

<details>
<summary>Create Network Resources</summary>

```hcl
# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags       = { Name = var.vpc_name }
}

# LAN Subnet
resource "aws_subnet" "lan" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_lan_cidr
  availability_zone = var.availability_zone
  tags              = { Name = var.subnet_lan_name }
}

resource "aws_network_interface" "lan" {
  subnet_id   = aws_subnet.lan.id
  private_ips = [var.lan_private_ip]
  tags        = { Name = "${var.subnet_lan_name}-nic" }
}

# WAN Subnet
resource "aws_subnet" "wan" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_wan_cidr
  availability_zone = var.availability_zone
  tags              = { Name = var.subnet_wan_name }
}

resource "aws_network_interface" "wan" {
  subnet_id   = aws_subnet.wan.id
  private_ips = [var.wan_private_ip]
  tags        = { Name = "${var.subnet_wan_name}-nic" }
}

# Management Subnet
resource "aws_subnet" "mgmt" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_mgmt_cidr
  availability_zone = var.availability_zone
  tags              = { Name = var.subnet_mgmt_name }
}

resource "aws_network_interface" "mgmt" {
  subnet_id   = aws_subnet.mgmt.id
  private_ips = [var.mgmt_private_ip]
  tags        = { Name = "${var.subnet_mgmt_name}-nic" }
}

# Management Subnet - public IP
resource "aws_eip" "mgmt_public" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.mgmt.id
  associate_with_private_ip = var.mgmt_private_ip
  depends_on                = [aws_internet_gateway.igw]
  tags                      = { Name = "${var.subnet_mgmt_name}-eip" }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.vpc_name}-igw" }
}

# Mgmt Route Table - public
resource "aws_route_table" "mgmt_public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = var.subnet_mgmt_name }
}

resource "aws_route_table_association" "mgmt_public" {
  subnet_id      = aws_subnet.mgmt.id
  route_table_id = aws_route_table.mgmt_public.id
}



########################
# Security Groups
########################

resource "aws_security_group" "public_mgmt" {
  name        = "example-public-sg"
  description = "Allow SSH and outbound traffic"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "example-public-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.public_mgmt.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags = {
    Name = "example-all-egress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "icmp" {
  security_group_id = aws_security_group.public_mgmt.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  to_port           = -1
  ip_protocol       = "icmp"
  tags = {
    Name = "example-icmp-ingress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.allowed_cidrs)

  security_group_id = aws_security_group.public_mgmt.id
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  tags = {
    Name = "example-http-ingress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = toset(var.allowed_cidrs)

  security_group_id = aws_security_group.public_mgmt.id
  cidr_ipv4         = each.value
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  tags = {
    Name = "example-ssh-ingress"
  }
}
```

</details>

### Create new AppConnector EC2 Virtual Machine and Related Cato CMA Configuration

```hcl
// AppConnector Resource
module "app_conn" {
  source = "catonetworks/appconnector-aws/cato"

  # VM settings
  ebs_disk_size = 32
  ebs_disk_type = "gp3"
  instance_type = "t3.large"
  mgmt_eni_id   = aws_network_interface.mgmt.id
  wan_eni_id    = aws_network_interface.wan.id
  lan_eni_id    = aws_network_interface.lan.id

  # AppConnector settings
  app_connector_name          = "appcon-site1"
  app_connector_description   = "make site1 app accessible"
  app_connector_group         = "site1"
  app_connector_address       = "123 Main St"
  app_connector_city          = "San Francisco"
  app_connector_country_code  = "US"
  app_connector_state_code    = "US-CA"
  app_connector_timezone      = "America/Los_Angeles"
  app_connector_primary_pop   = "New York_Sta"
  app_connector_secondary_pop = "Chicago Sta"
  
  # Example Tags
  tags = {
    Environment = "Production"
  }
}
```

## Authors

Module is maintained by [Cato Networks](https://github.com/catonetworks) with help from [these awesome contributors](https://github.com/catonetworks/terraform-cato-appconnector-aws/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/catonetworks/terraform-cato-appconnector-aws/tree/master/LICENSE) for full details.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.98.00 |
| <a name="requirement_cato"></a> [cato](#requirement\_cato) | >= 0.0.70 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.98.00 |
| <a name="provider_cato"></a> [cato](#provider\_cato) | >= 0.0.70 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_instance.app_connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface_attachment.mgmt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [aws_network_interface_attachment.wan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [cato_app_connector.this](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/app_connector) | resource |
| [aws_ami.appConnector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ami_owner"></a> [ami\_owner](#input\_ami\_owner) | AMI owner to lookup the appConnector image in AWS Marketplace. | `string` | `"aws-marketplace"` | no |
| <a name="input_ami_regex"></a> [ami\_regex](#input\_ami\_regex) | AMI regex to lookup the appConnector image in AWS Marketplace. | `string` | `"APP_CONNECTOR_AWS"` | no |
| <a name="input_app_connector_address"></a> [app\_connector\_address](#input\_app\_connector\_address) | AppConnector address (street) | `string` | `null` | no |
| <a name="input_app_connector_city"></a> [app\_connector\_city](#input\_app\_connector\_city) | AppConnector city name (in the given country) | `string` | n/a | yes |
| <a name="input_app_connector_country_code"></a> [app\_connector\_country\_code](#input\_app\_connector\_country\_code) | AppConnector country code | `string` | n/a | yes |
| <a name="input_app_connector_description"></a> [app\_connector\_description](#input\_app\_connector\_description) | AppConnector description | `string` | `null` | no |
| <a name="input_app_connector_group"></a> [app\_connector\_group](#input\_app\_connector\_group) | AppConnector group name | `string` | n/a | yes |
| <a name="input_app_connector_name"></a> [app\_connector\_name](#input\_app\_connector\_name) | Name of the App Connector | `string` | `"app-connector"` | no |
| <a name="input_app_connector_pop_location_automatic"></a> [app\_connector\_pop\_location\_automatic](#input\_app\_connector\_pop\_location\_automatic) | Whether the POP location for the AppConnector should be automatically selected | `bool` | `true` | no |
| <a name="input_app_connector_pop_location_preferred_only"></a> [app\_connector\_pop\_location\_preferred\_only](#input\_app\_connector\_pop\_location\_preferred\_only) | Whether to only use the preferred POP location for the AppConnector | `bool` | `false` | no |
| <a name="input_app_connector_primary_pop"></a> [app\_connector\_primary\_pop](#input\_app\_connector\_primary\_pop) | Primary POP location (state) for the AppConnector | `string` | `null` | no |
| <a name="input_app_connector_secondary_pop"></a> [app\_connector\_secondary\_pop](#input\_app\_connector\_secondary\_pop) | Secondary POP location (state) for the AppConnector | `string` | `null` | no |
| <a name="input_app_connector_state_code"></a> [app\_connector\_state\_code](#input\_app\_connector\_state\_code) | AppConnector state code (required for the USA) | `string` | n/a | yes |
| <a name="input_app_connector_timezone"></a> [app\_connector\_timezone](#input\_app\_connector\_timezone) | AppConnector timezone | `string` | n/a | yes |
| <a name="input_ebs_disk_size"></a> [ebs\_disk\_size](#input\_ebs\_disk\_size) | Size of disk | `number` | `32` | no |
| <a name="input_ebs_disk_type"></a> [ebs\_disk\_type](#input\_ebs\_disk\_type) | Size of disk | `string` | `"gp3"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type of the appConnector | `string` | `"c5.xlarge"` | no |
| <a name="input_lan_eni_id"></a> [lan\_eni\_id](#input\_lan\_eni\_id) | LAN Elastic Network Interface ID, network interface connected to a private subnet for local VPC resources to connect to for access to internet and WAN access through the Cato socket. Example: eni-abcde12345abcde12345 | `string` | n/a | yes |
| <a name="input_mgmt_eni_id"></a> [mgmt\_eni\_id](#input\_mgmt\_eni\_id) | Managent Elastic Network Interface ID, network interface connected public to a subnet with routable access to the internet to access the internet and the Cato SASE cloud platform. Example: eni-abcde12345abcde12345 | `string` | n/a | yes |
| <a name="input_ssh_key_pair_name"></a> [ssh\_key\_pair\_name](#input\_ssh\_key\_pair\_name) | Name of an existing Key Pair for SSH access to the AppConnector instance | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be appended to AWS resources | `map(string)` | `{}` | no |
| <a name="input_wan_eni_id"></a> [wan\_eni\_id](#input\_wan\_eni\_id) | WAN Elastic Network Interface ID, network interface connected to a public subnet with routable access to the internet to access the internet and the Cato SASE cloud platform. Example: eni-abcde12345abcde12345 | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_app_connector_description"></a> [app\_connector\_description](#output\_app\_connector\_description) | The description of the Cato App Connector |
| <a name="output_app_connector_group_name"></a> [app\_connector\_group\_name](#output\_app\_connector\_group\_name) | The group name of the Cato App Connector |
| <a name="output_app_connector_id"></a> [app\_connector\_id](#output\_app\_connector\_id) | The ID of the Cato App Connector |
| <a name="output_app_connector_name"></a> [app\_connector\_name](#output\_app\_connector\_name) | The name of the Cato App Connector |
| <a name="output_app_connector_serial_number"></a> [app\_connector\_serial\_number](#output\_app\_connector\_serial\_number) | The serial number of the Cato App Connector |
| <a name="output_app_connector_socket_id"></a> [app\_connector\_socket\_id](#output\_app\_connector\_socket\_id) | The socket ID of the Cato App Connector |
| <a name="output_instance_arn"></a> [instance\_arn](#output\_instance\_arn) | The ARN of the App Connector EC2 instance |
| <a name="output_instance_availability_zone"></a> [instance\_availability\_zone](#output\_instance\_availability\_zone) | The availability zone of the App Connector EC2 instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The ID of the App Connector EC2 instance |
| <a name="output_instance_private_ip"></a> [instance\_private\_ip](#output\_instance\_private\_ip) | The private IP address of the App Connector EC2 instance |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | The public IP address of the App Connector EC2 instance |
| <a name="output_instance_state"></a> [instance\_state](#output\_instance\_state) | The state of the App Connector EC2 instance |
<!-- END_TF_DOCS -->

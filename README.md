# CATO APP CONNECTOR AWS Terraform module

Terraform module which creates an AWS App Connector in the Cato Management Application (CMA), and deploys a virtual app connector ec2 instance in AWS used to connect private applications over the Cat network.

## Usage

```hcl
// Initialize Providers
provider "aws" {
  region = "us-east-2"
}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "baseurl" {}
variable "token" {}
variable "account_id" {}


// Virtual Socket Resource
module "vsocket-aws" {
  source = "catonetworks/appconnector-aws/cato"
  region               = var.region
  vpc_id               = "vpc-abcde12345abcde"
  key_pair             = "your-keypair-name-here"
  subnet_range_lan     = "10.0.3.0/24"
  mgmt_eni_id          = "eni-abcde12345abcde12mgmt"
  wan_eni_id           = "eni-abcde12345abcde123wan"
  lan_eni_id           = "eni-abcde12345abcde123lan"
  lan_local_ip         = "10.0.3.5"
  app_conn_name        = "AWS App Connector us-east-2"
  site_description     = "AWS App Connector us-east-2"
  # site location is inferred from aws region 
  
  # Example Tags
  tags = {
    Environment = "Production"
    ApplicationName = "Custom App"
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
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.98.00 |
| <a name="requirement_cato"></a> [cato](#requirement\_cato) | >= 0.0.38 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.98.00 |
| <a name="provider_cato"></a> [cato](#provider\_cato) | >= 0.0.38 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.vSocket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [cato_app_connector.app_conn](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/app_connector) | resource |
| [aws_ami.vSocket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [cato_siteLocation.app_conn_location](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/siteLocation) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_conn_description"></a> [app\_conn\_description](#input\_app\_conn\_description) | Site description | `string` | n/a | yes |
| <a name="input_app_conn_group_name"></a> [app\_conn\_group\_name](#input\_app\_conn\_group\_name) | Your Cato App Connector Group Name Here | `string` | n/a | yes |
| <a name="input_app_conn_location"></a> [app\_conn\_location](#input\_app\_conn\_location) | Site location which is used by the Cato Socket to connect to the closest Cato PoP. If not specified, the location will be derived from the Azure region dynamicaly. | <pre>object({<br/>    city_name         = string<br/>    country_code = string<br/>    state_code   = string<br/>    timezone     = string<br/>  })</pre> | <pre>{<br/>  "city_name": null,<br/>  "country_code": null,<br/>  "state_code": null,<br/>  "timezone": null<br/>}</pre> | no |
| <a name="input_app_conn_name"></a> [app\_conn\_name](#input\_app\_conn\_name) | Your Cato Site Name Here | `string` | n/a | yes |
| <a name="input_connection_type"></a> [connection\_type](#input\_connection\_type) | Model of Cato vsocket | `string` | `"SOCKET_AWS1500"` | no |
| <a name="input_ebs_disk_size"></a> [ebs\_disk\_size](#input\_ebs\_disk\_size) | Size of disk | `number` | `32` | no |
| <a name="input_ebs_disk_type"></a> [ebs\_disk\_type](#input\_ebs\_disk\_type) | Size of disk | `string` | `"gp3"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type of the vSocket | `string` | `"c5.xlarge"` | no |
| <a name="input_key_pair"></a> [key\_pair](#input\_key\_pair) | Name of an existing Key Pair for AWS encryption | `string` | `"your-key-pair-name-here"` | no |
| <a name="input_lan_eni_id"></a> [lan\_eni\_id](#input\_lan\_eni\_id) | LAN Elastic Network Interface ID, network interface connected to a private subnet for local VPC resources to connect to for access to internet and WAN access through the Cato socket. Example: eni-abcde12345abcde12345 | `string` | n/a | yes |
| <a name="input_lan_local_ip"></a> [lan\_local\_ip](#input\_lan\_local\_ip) | Choose an IP Address within the LAN Subnet. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface used as the default route for private resources to gain access to WAN and internet. The accepted input format is X.X.X.X | `string` | n/a | yes |
| <a name="input_mgmt_eni_id"></a> [mgmt\_eni\_id](#input\_mgmt\_eni\_id) | Managent Elastic Network Interface ID, network interface connected public to a subnet with routable access to the internet to access the internet and the Cato SASE cloud platform. Example: eni-abcde12345abcde12345 | `string` | n/a | yes |
| <a name="input_preferred_pop_location_automatic"></a> [preferred\_pop\_location\_automatic](#input\_preferred\_pop\_location\_automatic) | Automatic preferred pop location selection | `bool` | `true` | no |
| <a name="input_preferred_pop_location_preferred_only"></a> [preferred\_pop\_location\_preferred\_only](#input\_preferred\_pop\_location\_preferred\_only) | Automatic preferred pop location selection to use preferred locations only | `bool` | `true` | no |
| <a name="input_preferred_pop_location_primary"></a> [preferred\_pop\_location\_primary](#input\_preferred\_pop\_location\_primary) | Preferred pop location - primary | `string` | `null` | no |
| <a name="input_preferred_pop_location_secondary"></a> [preferred\_pop\_location\_secondary](#input\_preferred\_pop\_location\_secondary) | Preferred pop location - secondary | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_routed_networks"></a> [routed\_networks](#input\_routed\_networks) | A map of routed networks to be accessed behind the vSocket site.<br/>  The key is the network name. The value is an object with the following attributes:<br/>  - subnet (string, required): The CIDR range of the network.<br/>  - interface\_index (string, optional): The site interface the network is connected to. Defaults to "LAN1". | <pre>map(object({<br/>    subnet          = string<br/>    interface_index = optional(string, "LAN1")<br/>  }))</pre> | `{}` | no |
| <a name="input_subnet_range_lan"></a> [subnet\_range\_lan](#input\_subnet\_range\_lan) | Choose a range within the VPC to use as the Private/LAN subnet. This subnet will host the target LAN interface of the vSocket so resources in the VPC (or AWS Region) can route to the Cato Cloud.<br/>    The minimum subnet length to support High Availability is /29.<br/>    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be appended to AWS resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |
| <a name="input_wan_eni_id"></a> [wan\_eni\_id](#input\_wan\_eni\_id) | WAN Elastic Network Interface ID, network interface connected to a public subnet with routable access to the internet to access the internet and the Cato SASE cloud platform. Example: eni-abcde12345abcde12345 | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_conn_location"></a> [app\_conn\_location](#output\_app\_conn\_location) | n/a |
<!-- END_TF_DOCS -->
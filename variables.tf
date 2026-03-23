variable "app_connector_name" {
  type        = string
  description = "Name of the App Connector"
  default     = "app-connector"
}

# AppConnector VM Settings
variable "instance_type" {
  description = "The instance type of the appConnector"
  type        = string
  default     = "c5.xlarge"
  validation {
    condition     = contains(["d2.xlarge", "c3.xlarge", "t3.large", "t3.xlarge", "c4.xlarge", "c5.xlarge", "c5d.xlarge", "c5n.xlarge"], var.instance_type)
    error_message = "The instance_type variable must be one of 'd2.xlarge','c3.xlarge','t3.large','t3.xlarge','c4.xlarge','c5.xlarge','c5d.xlarge','c5n.xlarge'."
  }
}

variable "ami_regex" {
  description = "AMI regex to lookup the appConnector image in AWS Marketplace."
  type        = string
  default     = "APP_CONNECTOR_AWS"
}

variable "ami_owner" {
  description = "AMI owner to lookup the appConnector image in AWS Marketplace."
  type        = string
  default     = "aws-marketplace"
}

variable "ebs_disk_size" {
  description = "Size of disk"
  type        = number
  default     = 32
}

variable "ebs_disk_type" {
  description = "Size of disk"
  type        = string
  default     = "gp3"
}

variable "ssh_key_pair_name" {
  description = "Name of an existing Key Pair for SSH access to the AppConnector instance"
  type        = string
  default     = null
}

variable "mgmt_eni_id" {
  description = "Managent Elastic Network Interface ID, network interface connected public to a subnet with routable access to the internet to access the internet and the Cato SASE cloud platform. Example: eni-abcde12345abcde12345"
  type        = string
}

variable "wan_eni_id" {
  description = "WAN Elastic Network Interface ID, network interface connected to a public subnet with routable access to the internet to access the internet and the Cato SASE cloud platform. Example: eni-abcde12345abcde12345"
  type        = string
}

variable "lan_eni_id" {
  description = "LAN Elastic Network Interface ID, network interface connected to a private subnet for local VPC resources to connect to for access to internet and WAN access through the Cato socket. Example: eni-abcde12345abcde12345"
  type        = string
}

variable "tags" {
  description = "Tags to be appended to AWS resources"
  type        = map(string)
  default     = {}
}

## AppConnector resource settings in the Cato Management Application 
variable "app_connector_description" {
  description = "AppConnector description"
  type        = string
  default     = null
}
variable "app_connector_group" {
  description = "AppConnector group name"
  type        = string
}

variable "app_connector_address" {
  description = "AppConnector address (street)"
  type        = string
  default     = null
}

variable "app_connector_city" {
  description = "AppConnector city name (in the given country)"
  type        = string
}

variable "app_connector_country_code" {
  description = "AppConnector country code"
  type        = string
}

variable "app_connector_state_code" {
  description = "AppConnector state code (required for the USA)"
  type        = string
}

variable "app_connector_timezone" {
  description = "AppConnector timezone"
  type        = string
}

variable "app_connector_primary_pop" {
  description = "Primary POP location (state) for the AppConnector"
  type        = string
  default     = null
}

variable "app_connector_secondary_pop" {
  description = "Secondary POP location (state) for the AppConnector"
  type        = string
  default     = null
}

variable "app_connector_pop_location_automatic" {
  description = "Whether the POP location for the AppConnector should be automatically selected"
  type        = bool
  default     = true
}

variable "app_connector_pop_location_preferred_only" {
  description = "Whether to only use the preferred POP location for the AppConnector"
  type        = bool
  default     = false
}

## vSocket Module Varibables
variable "app_conn_description" {
  type        = string
  description = "App Connector description"
}

variable "app_conn_name" {
  type        = string
  description = "Your Cato App Connector Name Here"
}

variable "app_conn_group_name" {
  type        = string
  description = "Your Cato App Connector Group Name Here"
}

variable "preferred_pop_location_automatic" {
  description = "Automatic preferred pop location selection"
  type        = bool
  default     = true
}

variable "preferred_pop_location_preferred_only" {
  description = "Automatic preferred pop location selection to use preferred locations only"
  type        = bool
  default     = true
}

variable "preferred_pop_location_primary" {
  description = "Preferred pop location - primary"
  type        = string
  default     = null
}

variable "preferred_pop_location_secondary" {
  description = "Preferred pop location - secondary"
  type        = string
  default     = null
}


## Virtual Socket Variables
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "connection_type" {
  description = "Model of Cato vsocket"
  type        = string
  default     = "SOCKET_AWS1500"
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

variable "instance_type" {
  description = "The instance type of the vSocket"
  type        = string
  default     = "c5.xlarge"
  validation {
    condition     = contains(["d2.xlarge", "c3.xlarge", "t3.large", "t3.xlarge", "c4.xlarge", "c5.xlarge", "c5d.xlarge", "c5n.xlarge"], var.instance_type)
    error_message = "The instance_type variable must be one of 'd2.xlarge','c3.xlarge','t3.large','t3.xlarge','c4.xlarge','c5.xlarge','c5d.xlarge','c5n.xlarge'."
  }
}

variable "key_pair" {
  description = "Name of an existing Key Pair for AWS encryption"
  type        = string
  default     = "your-key-pair-name-here"
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

variable "lan_local_ip" {
  description = "Choose an IP Address within the LAN Subnet. You CANNOT use the first four assignable IP addresses within the subnet as it's reserved for the AWS virtual router interface used as the default route for private resources to gain access to WAN and internet. The accepted input format is X.X.X.X"
  type        = string
}

variable "tags" {
  description = "Tags to be appended to AWS resources"
  type        = map(string)
  default     = {}
}

variable "app_conn_location" {
  description = "App Connector location which is used by the Cato Socket to connect to the closest Cato PoP. If not specified, the location will be derived from the Azure region dynamicaly."
  type = object({
    city_name    = string
    country_code = string
    state_code   = string
    timezone     = string
  })
  default = {
    city_name    = null
    country_code = null
    state_code   = null ## Optional - for countries with states
    timezone     = null
  }
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "routed_networks" {
  description = <<EOF
  A map of routed networks to be accessed behind the vSocket App Connector.
  The key is the network name. The value is an object with the following attributes:
  - subnet (string, required): The CIDR range of the network.
  - interface_index (string, optional): The App Connector interface the network is connected to. Defaults to "LAN1".
  EOF
  type = map(object({
    subnet          = string
    interface_index = optional(string, "LAN1")
  }))
  default = {}
}

variable "subnet_range_lan" {
  type        = string
  description = <<EOT
    Choose a range within the VPC to use as the Private/LAN subnet. This subnet will host the target LAN interface of the vSocket so resources in the VPC (or AWS Region) can route to the Cato Cloud.
    The minimum subnet length to support High Availability is /29.
    The accepted input format is Standard CIDR Notation, e.g. X.X.X.X/X
	EOT
}

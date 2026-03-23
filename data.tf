## Lookup data from region and VPC
data "aws_ami" "appConnector" {
  most_recent = true
  name_regex  = var.ami_regex
  owners      = [var.ami_owner]
}

data "aws_availability_zones" "available" {
  state = "available"
}

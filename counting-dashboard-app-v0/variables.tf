variable "region" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1"
}

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
  default     = "counting-dashboard"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "environment" {
  default     = "Production"
  description = "target environment"
}

variable "dashboard-subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}


variable "counting-subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.20.0/24"
}

variable "instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t3.micro"
}

variable "department" {
  default     = "devops"
  description = "department"
}


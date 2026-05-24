variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
  default     = "eu-west-2a"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "pov"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "availability_zone_b" {
  description = "Second availability zone for the RDS subnet group"
  type        = string
  default     = "eu-west-2b"
}

variable "db_subnet_cidr_1" {
  description = "CIDR block for the first database subnet (eu-west-2a)"
  type        = string
  default     = "10.0.3.0/24"
}

variable "db_subnet_cidr_2" {
  description = "CIDR block for the second database subnet (eu-west-2b)"
  type        = string
  default     = "10.0.4.0/24"
}

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "countingdb"
}

variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "dbadmin"
}

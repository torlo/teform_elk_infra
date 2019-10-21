#Variables for Network part
#MAde by TOR

variable "torlo-vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs in this region to use"
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
  type        = "list"
}

variable "subnet_cidrs_public" {
  description = "Subnet CIDRs for public subnets"
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
  type        = "list"
}
variable "subnet_cidrs_private" {
  description = "Subnet CIDRs for private subnets"
  default     = ["10.0.110.0/24", "10.0.111.0/24"]
  type        = "list"
}

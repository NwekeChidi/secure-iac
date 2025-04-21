variable "cidr_block" {
  description = "Base CIDR block for VPCs"
  type = string
}

variable "name" {
  description = "Name prefix for all network objects"
  type = string
}

variable "level" {}

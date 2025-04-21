# Network Module
variable "env_name" {
  type = string
}
variable "aws_profile" {}
variable "aws_region" {}
variable "vpc_cidr" {}
locals {
  name = "sec-iac-${var.env_name}"
  level = "worldclass"
}

variable "common_tags" {}
variable "target_url" {}
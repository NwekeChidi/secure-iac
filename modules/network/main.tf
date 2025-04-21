resource "aws_vpc" "sec_iac_vpc" {
  cidr_block = var.cidr_block
  instance_tenancy = "default"
  tags = {
    Name = "${var.name}-vpc"
    Env = var.level
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.sec_iac_vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, 0)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-public"
    Env = var.level
  }
}
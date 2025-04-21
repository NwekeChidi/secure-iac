output "vpc_id" {
  value = aws_vpc.sec_iac_vpc.id
}
output "subnet_id" {
  value = aws_subnet.public.id
}
output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.vpc_public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.vpc_private_subnet.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.my_nat_gateway.id
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}

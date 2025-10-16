output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_id_a" {
  value = aws_subnet.vpc_public_subnet_a.id
}

output "public_subnet_id_b" {
  value = aws_subnet.vpc_public_subnet_b.id
}

/*
output "private_subnet_a_id" {
  value = aws_subnet.vpc_private_subnet_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.vpc_private_subnet_b.id
}
*/

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_instance_addr" {
  value = aws_db_instance.postgres.address
}

output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}

output "ec2_public_dns" {
  value = aws_instance.ec2.public_dns
}

/*
output "elastic_ip_address" {
  value = aws_eip.nat_eip.public_ip
}

output "nat_gateway_id" {
  value = aws_nat_gateway.my_nat_gateway.id
}
*/
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnet1_id" {
  value = aws_subnet.public_subnet_1.id
}
output "public_subnet2_id" {
  value = aws_subnet.public_subnet_2.id
}

output "security_group_id" {
  value = aws_security_group.alb_sg.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main_igw.id
}

output "route_table_id" {
  value = aws_route_table.public_rt.id
}

output "aws_alb_id" {
  value = aws_alb.app_alb.id
}

output "aws_alb_target_group_id" {
  value = aws_alb_target_group.tg.id
}

output "launch_template_id" {
  value = aws_launch_template.app_server_1.id
}
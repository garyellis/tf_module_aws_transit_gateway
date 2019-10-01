output "id" {
  value = join("", aws_ec2_transit_gateway.tgw.*.id)
}

output "arn" {
  value = join("", aws_ec2_transit_gateway.tgw.*.arn)
}

output "attachment_id" {
  value = join("", aws_ec2_transit_gateway_vpc_attachment.tgw.*.id)
}

output "route_table_id" {
  value = join("", aws_ec2_transit_gateway_route_table.tgw.*.id)
}

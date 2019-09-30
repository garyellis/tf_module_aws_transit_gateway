output "id" {
  value = join("", aws_ec2_transit_gateway.tgw.*.id)
}

output "arn" {
  value = join("", aws_ec2_transit_gateway.tgw.*.arn)
}

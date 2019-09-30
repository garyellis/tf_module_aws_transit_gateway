#### create the transit gateway
resource "aws_ec2_transit_gateway" "tgw" {
  count = var.create_tgw ? 1 : 0

  description                     = var.tgw_description
  amazon_side_asn                 = null
  default_route_table_association = var.tgw_default_route_table_association
  default_route_table_propagation = var.tgw_default_route_table_propagation
  tags                            = merge(map("Name", var.name), var.tags)
}

locals {
  tgw_id  = var.create_tgw ? join("", aws_ec2_transit_gateway.tgw.*.id) : join("", list(var.tgw_id))
  tgw_arn = var.create_tgw ? join("", aws_ec2_transit_gateway.tgw.*.arn) : join("", list(var.tgw_arn))
}


#### setup the resource share
resource "aws_ram_resource_share" "tgw" {
  count = var.create_tgw && var.create_ram_share ? 1 : 0

  name = var.name
  tags = merge(map("Name", var.name), var.tags)
}

locals {
  resource_share_arn = var.create_ram_share ? join("", aws_ram_resource_share.tgw.*.arn) : join("", list(var.ram_share_arn))
}

resource "aws_ram_resource_association" "tgw_ram_share" {
  count = var.create_tgw && var.create_ram_share ? 1 : 0

  resource_arn       = local.tgw_arn
  resource_share_arn = local.resource_share_arn
}

resource "aws_ram_resource_association" "tgw_use_existing_ram_share" {
  count = var.create_tgw && var.use_existing_ram_share ? 1 : 0

  resource_arn       = local.tgw_arn
  resource_share_arn = local.resource_share_arn
}


resource "aws_ram_principal_association" "tgw" {
  count = length(var.resource_share_principals)

  principal          = element(var.resource_share_principals, count.index)
  resource_share_arn = local.resource_share_arn
}


#### transit gateway vpn customer gateway
resource "aws_customer_gateway" "tgw" {
  count = var.create_customer_gateway ? 1 : 0
  bgp_asn    = 65000
  ip_address = "172.0.0.1"
  type       = "ipsec.1"
  tags       = merge(map("Name", var.customer_gateway_name), var.tags)
}

# setup a local to allow use existing cgw
resource "aws_vpn_connection" "tgw" {
  count = var.create_customer_gateway ? 1 : 0

  customer_gateway_id = aws_customer_gateway.tgw.0.id
  transit_gateway_id  = local.tgw_id
  type                = aws_customer_gateway.tgw.0.type
  tags       = merge(map("Name", var.customer_gateway_name), var.tags)
}

# an aws vpn connection associated directly to a tgw id. its tags do not propagated to the attachment resource under transit gateway attachments


#### setup the vpc attachment and routing
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw" {
  count = var.create_tgw_attachment ? 1 : 0

  subnet_ids                                      = var.vpc_attachment_subnet_ids
  transit_gateway_id                              = local.tgw_id
  vpc_id                                          = var.vpc_attachment_vpc_id
  transit_gateway_default_route_table_association = var.vpc_attachment_default_route_table_association
  transit_gateway_default_route_table_propagation = var.vpc_attachment_default_route_table_propagation
  tags                                            = merge(map("Name", var.name), var.tags)
}

resource "aws_ec2_transit_gateway_route_table" "tgw" {
  count = var.create_tgw_attachment && var.create_tgw_route_table ? 1 : 0

  transit_gateway_id = local.tgw_id
  tags = merge(map("Name", var.name), var.tags)
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw" {
  count = var.create_tgw_attachment && var.create_tgw_route_table ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw.0.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw.0.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw" {
  count = var.create_tgw_attachment && var.create_tgw_route_table ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw.0.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw.0.id
}

resource "aws_ec2_transit_gateway_route" "tgw" {
  count = var.create_tgw_attachment && var.create_tgw_route_table ? length(var.tgw_route_table_routes) : 0

  destination_cidr_block         = element(var.tgw_route_table_routes, count.index)
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.tgw.0.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw.0.id
}


data "aws_route_tables" "vpc" {
  count = var.create_tgw_attachment && var.create_tgw_route_table ? 1 : 0
  vpc_id = var.vpc_attachment_vpc_id
}

locals {
  route_table_ids = length(var.vpc_route_table_ids) > 0 ? var.vpc_route_table_ids :  flatten(data.aws_route_tables.vpc.*.ids)
  vpc_routes = flatten([
    for i in local.route_table_ids: [
      for x in var.tgw_route_table_routes: {
        route_table_id = i
        destination_cidr_block = x
      }
    ]
  ])
}

resource "aws_route" "vpc" {
  count = var.create_tgw_attachment ? length(local.vpc_routes) : 0

  route_table_id         = lookup(local.vpc_routes[count.index], "route_table_id")
  destination_cidr_block = lookup(local.vpc_routes[count.index], "destination_cidr_block")
  transit_gateway_id     = local.tgw_id
}

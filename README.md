# tf_module_aws_transit_gateway

This terraform module manages AWS Transit Gateway Resources. It supports the following usage combinations:

* TGW creation and resource share to one or more accounts.
* TGW VPC attachment, resource share acceptor,TGW route table, TGW route table routes, and vpc routes.
* TGW VPN attachment.


## Usage

Create a vpc, transit gateway, vpc attachment and vpn attachment from a "hub" account. (terraform variable values are not here for brevity.)
```bash
### setup our shared services vpc
data "aws_availability_zones" "azs" {}

locals {
  azs = [data.aws_availability_zones.azs.names[0], data.aws_availability_zones.azs.names[1]]
}

module "vpc" {
  source = "github.com/garyellis/tf_module_aws_vpc"

  azs                        = local.azs
  name                       = var.name
  public_subnets             = var.vpc_public_subnets
  private_subnets            = var.vpc_private_subnets
  private_restricted_subnets = var.vpc_intra_subnets
  enable_natgw               = true
  vpc_cidr                   = var.vpc_cidr
  tags                       = var.tags
}

module "tgw" {
  source = "../../../terraform-modules/transit-gateway"

  create_tgw              = true
  create_ram_share        = false
  use_existing_ram_share  = false
  name                    = format("%s-transit", var.name)
  create_tgw_attachment   = false
  create_customer_gateway = true
  customer_gateway_name   = "dcwest"
  tags                    = var.tags
}

module "tgw_vpc_attachment" {
  source = "../../../terraform-modules/transit-gateway"

  create_tgw_attachment     = true
  tgw_id                    = module.tgw.id
  name                      = var.name
  vpc_attachment_name       = var.name
  vpc_attachment_vpc_id     = module.vpc.vpc_id
  vpc_attachment_subnet_ids = [module.vpc.private_subnets[0].id, module.vpc.private_subnets[1].id]
  create_tgw_route_table    = true
  tgw_route_table_routes    = ["172.26.8.0/21", "172.26.16.0/22"]
  tags                      = var.tags
}

```


Create a spoke vpc, transit gateway vpc attachment. (terraform variable values are not here for brevity.)
```bash
### setup our shared services vpc
data "aws_availability_zones" "azs" {}

locals {
  azs = [data.aws_availability_zones.azs.names[0], data.aws_availability_zones.azs.names[1]]
}

module "vpc" {
  source = "github.com/garyellis/tf_module_aws_vpc"

  azs                        = local.azs
  name                       = var.name
  public_subnets             = var.vpc_public_subnets
  private_subnets            = var.vpc_private_subnets
  private_restricted_subnets = var.vpc_intra_subnets
  enable_natgw               = true
  vpc_cidr                   = var.vpc_cidr
  tags                       = var.tags
}

# lookup the tgw id or pass it in as an environment variable
module "tgw_vpc_attachment" {
  source = "../../../terraform-modules/transit-gateway"

  create_tgw_attachment     = true
  tgw_id                    = "tgw-0ab31c7fbfa1a1c85"
  name                      = var.name
  vpc_attachment_name       = var.name
  vpc_attachment_vpc_id     = module.vpc.vpc_id
  vpc_attachment_subnet_ids = [module.vpc.private_subnets[0].id, module.vpc.private_subnets[1].id]
  create_tgw_route_table    = true
  tgw_route_table_routes    = ["172.26.0.0/21"]
  tags                      = var.tags
}

```


## Terraform Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | A common name to identify resources | `string` | n/a | yes |
| tags | A map of tags applied to taggable resources | `map(string)` | `{}` | no |
| create\_tgw | Create a transit gateway | `bool` | `n/a` | yes |
| tgw\_id | An existing tgw id for  transit gateway attachments | `string` | `""` | no |
| tgw\_arn | An existing tgw arn. | `string` | `""` | no |
| tgw\_description | The transit gateway description. Use when creating transit gateways. | `string` | `""` | no |
| tgw\_default\_route\_table\_association | associate the default tgw route table. | `string` | "disable" | no |
| tgw\_default\_route\_table\_propagation | enable route table table propagation. | `string` | "disable" | no |
| create\_ram\_share | create an aws ram share and share the tgw. | `bool` | `false` | no |
| use\_existing\_ram\_share | shares a tgw on an existing ram share. | `bool` | `false` | no |
| ram\_share\_arn | The ram share ARN. | `string` | `""` | required when using an existing RAM share. |
| resource\_share\_principals | Share the tgw resource to the list of AWS accounts | `list(string)` | `[]` | no |
| create\_tgw\_attachment (should change to tgw\_vpc\_attachment) | create a tgw vpc attachment. | `bool` | `false` | no |
| vpc\_attachment\_name | the tgw vpc attachment name | `string` | `""` | required when `create_tgw_attachment` is `true` | 
| vpc\_attachment\_vpc\_id | the vpc id for the tgw vpc attachment | `string` | `""` | required when `create_tgw_attachment` is `true` |
| vpc\_attachment\_subnet\_ids | the vpc tgw attachment subnets. Only one subnet per AZ may be used. | `list(string)` | `[]` | required when `create_tgw_attachment` is `true` |
| vpc\_attachment\_default\_route\_table\_association | associate the vpc attachment to the default tgw route table | `bool` | `false` | no |
| vpc\_attachment\_default\_route\_table\_propagation | associate the vpc attachment to the default tgw route table | `bool` | `false` | no |
| create\_tgw\_route\_table | creates a route table for the vpc attachment | `bool` | `false` | no |
| tgw\_route\_table\_routes | destination cidrs applied to the vpc attachment route table and vpc route tables | `list(string)` | `[]` | no |
| vpc\_route\_table\_ids | an optional list of vpc route tables. when not set tgw route destinations are applied to all vpc route tables. | `list(string)` | `[]` | no |
| create\_customer\_gateway | creates a customer gateway and tgw vpn attachment. | `bool` | `false` | no | 
| customer\_gateway\_name | the customer gateway and vpn connection and attachment name. | `string` | `""` | no |

## Terraform Output Variables




## todo items
* add vpn connection and custoemr gateway variable inputs
* ensure that all route table routes are optional
* add additional routes list of maps to create
* add resource acceptor as an optional resource
* ensure variable input names are consistent and easy to understand.
* populate tags for the tgw vpn attachment resource. (these are not propagated to the tgw attachment automatically)
* populate examples
* add ci to build (including version tagging)
* add changelog
* add output variables
* 

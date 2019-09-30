variable "name" {
  description = "A name common to all resources"
  type = string
  default = ""
}

variable "tags" {
  description = "a map of tags applied to all taggable resources"
  type = map(string)
  default = {}
}

#### transit gateway and share variables
variable "create_tgw" {
  description = "when true creates the transit gateway"
  type = bool
  default = false
}

variable "tgw_id" {
  description = "an existing transit gateway id."
  type = string
  default = ""
}

variable "tgw_arn" {
  description = "an existing transit gateway arn"
  type = string
  default = ""
}

variable "tgw_description" {
  description = "the transit gateway description"
  type = string
  default = ""
}

variable "tgw_default_route_table_association" {
  description = "transit gateway is associated to the default route table"
  type = string
  default = "disable"
}

variable "tgw_default_route_table_propagation" {
  description = "transit gateway is associated to the default route table with route propagation enabled"
  type = string
  default = "disable"
}

variable "create_ram_share" {
  description = "when true and create_tgw is true creates a ram share and shares the tgw"
  type = bool
  default = false
}

variable "use_existing_ram_share" {
  description = "when true and create tgw is true shares the tgw to an existing ram share"
  type = bool
  default = false
}

variable "ram_share_arn" {
  description = "the existing ram share arn. is required when use_existing_ram_share is true"
  type = bool
  default = false
}

variable "resource_share_principals" {
  description = "share the resource share to the list of aws accounts"
  type = list(string)
  default = []
}

#### vpc attachments and route tables
variable "create_tgw_attachment" {
  description = "create a vpc to tgw attachment"
  type = bool
  default = false
}

variable "vpc_attachment_name" {
  description = "the transit gateway vpc attachment name"
  type = string
  default = ""
}

variable "vpc_attachment_vpc_id" {
  description = "the transit gateway attachment vpc id"
  type = string
  default = ""
}

variable "vpc_attachment_subnet_ids" {
  description = "a list of transit gateway attachment subnet ids. Only one per AZ can be used"
  type = list(string)
  default = []
}

variable "vpc_attachment_default_route_table_association" {
  description = "when true the default route table is associated to the tgw"
  type = bool
  default = false
}

variable "vpc_attachment_default_route_table_propagation" {
  description = "when true route table propagation is enabled"
  type = bool
  default = false
}

variable "create_tgw_route_table" {
  description = "create a transit gateway route table"
  type = bool
  default = false
}

variable "tgw_route_table_routes" {
  description = "transit gateway table routes"
  type = list(string)
  default = []
}

variable "vpc_route_table_ids" {
  description = ""
  type = list(string)
  default = []
}


#### vpn gateway attachment
variable "create_customer_gateway" {
  description = "create a customer gateway associated to the tgw"
  type = bool
  default = false
}

variable "customer_gateway_name" {
  description = "the customer gateway name"
  type = string
 

 default = ""
}

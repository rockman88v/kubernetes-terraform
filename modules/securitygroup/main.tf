data "aws_vpc" "default" {
  default = true
}

locals {
  vpc_id       = var.vpc_id == "" ? data.aws_vpc.default.id : var.vpc_id
  vpc_cidr     = data.aws_vpc.default.cidr_block
  rules       = var.rules
  public_ports = var.public_ports
}

resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Security Group"
  vpc_id      = local.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "public_rules" {
  for_each          = toset(local.public_ports)
  type              = "ingress"
  description       = "Allow access from public for port ${each.value}"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "sg_rules" {
  for_each = { for rule in local.rules : (rule.port != null ? rule.port : "${rule.from_port}_${rule.to_port}") => rule }

  type              = "ingress"
  description       = "Allow inbound connection for port ${each.value.port != null ? each.value.port : each.value.from_port}"
  from_port         = each.value.port != null ? each.value.port : each.value.from_port
  to_port           = each.value.port != null ? each.value.port : each.value.to_port
  protocol          = each.value.protocol != null ? each.value.protocol : "tcp"
  cidr_blocks       = each.value.cidr_blocks != null ? each.value.cidr_blocks : [local.vpc_cidr]
  ipv6_cidr_blocks  = try(each.value.ipv6_cidr_blocks, null)
  security_group_id = aws_security_group.this.id
}

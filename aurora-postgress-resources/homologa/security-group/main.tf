resource "aws_security_group" "this" {
  name_prefix = var.name
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.sg_ingress
    content {
      from_port = ingress.key
      to_port   = ingress.key
      protocol  = "tcp"
      cidr_blocks = ingress.value
    }
  }
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
   tags = merge(var.tags)
}

###


# workers
resource "aws_security_group" "ekshub-node" {
  name        = "${var.name_prefix}-${var.ENV}"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = "${var.services_ports}"
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = "${var.IPS_VPC_ACCESS_EKS}"
    }
  }


  tags = {
    Name                             = "${var.name_prefix}"
    Terraform                        = "true"
    ambiente                         = "${var.ENV}"
    app                              = "${var.app}"
    modalidade                       = "sustentacao"
    Requerente                       = "${var.requerente}"
    "kubernetes.io/cluster/eks-bbce" = "shared"
  }
}

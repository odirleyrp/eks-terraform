variable "role_arn" {
  default = "arn:aws:iam::993324252386:role/Admin_AssumeRole"
}

variable "session_name" {
  default = "terraform_session"
}

variable "external_id" {
  default = "993324252386"
}


##----

variable vpc_id {
  type    = string
  default = "vpc-0cf709f226ed2bb13"
}

variable SUBNET_ID {
  type        = string
  default     = "subnet-0ac9c2b2d96670c30"
  description = "SUbnet da VPC"
}

variable SUBNET_ID_APP {
  type        = string
  default     = "subnet-0ac9c2b2d96670c30"
  description = "SUbnet da VPC"
}



variable AWS_REGION {
  type = string
  default     = "us-west-2"
  description = " Região da aws"
}

variable amiId {
  type        = string
  default     = "ami-098e42ae54c764c35"
  description = "id ami"
}

variable typeEc2 {
  type    = string
  default = "t3a.micro"
  description = " tipo de instancia"
}


variable PORT_CLUSTER {
  type        = string
  default     = "22"
  description = "POrta para acesso"
}

variable RANGE_SG_IPS {
  type    = list
  default = ["0.0.0.0/0"]
  description = "Lista de acesso de ips"

}



variable services_ports {
  type = list
  default = [
    "22"
  ]
  description = "lista de portas "
}


variable volume_size {
  type        = string
  default     = 8
  description = "Tamanho do volume"
}

variable volume_type {
  type        = string
  default     = "gp2"
  description = "Tipo de gp2"
}



variable KEYEC2 {
  type        = string
  default     = "goLiza-hml"
  description = "Chave para acesso"
}

variable name_prefix {
  type    = string
  default = "goLiza-hml"
}

variable ENV {
  type    = string
  default = "hml"
}

variable requerente {
  type    = string
  default = "goLiza"
}


variable modalidade {
  type        = string
  default     = "sustentacao"
  description = "tag"

}

variable ambiente {
  type        = string
  default     = "homologacao"
  description = "tag"

}

variable app {
  type        = string
  default     = "goLiza"
  description = "tag"


}

variable name {
  type = string
  default = "goLiza-hml"
  description = "tag"
}

variable key_name {
  type = string
  default = "goLiza-hml"
  description = "chave de seguranca"
}
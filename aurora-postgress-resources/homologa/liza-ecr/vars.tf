
#####################ECR#######################

variable ECR_PRODUTO {
  type        = string
  default     = "goliza"
  description = "nome do produto ou projeto"
}


variable AWS_REGION {
  type        = string
  default     = "us-west-2"
  description = "região que será aplicada"
}

variable ENV {
  type        = string
  default     = "bbce-shared"
  description = "Ambiente ou até mesmo a conta"
}

variable push {
  type        = string
  default     = "true"
  description = "Verificação de imagem docker, para verificar o conteudo da imagem"
}

variable MUTABLE {
  type        = string
  default     = "MUTABLE"
  description = " Se a tag será mutável"
}
module "ecr-api" {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/ecr-module"
  list_of_images = [
    "${var.ECR_PRODUTO}-api-${var.ENV}",
 
  ]
  iam_role = "${var.ECR_PRODUTO}-role-ecr-api-${var.ENV}"
  push     = "${var.push}"
  MUTABLE  = "${var.MUTABLE}"

 # tags = {
 #   Ambiente          = "PROD"
 #   Projeto           = "Liza"
 #   "Tipo de Capital" = "OPEX"
 #   Terraform         = true
 # }

}


##

module "ecr-web" {
  source = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/ecr-module"
  list_of_images = [
    "${var.ECR_PRODUTO}-web-${var.ENV}",
 
  ]
  iam_role = "${var.ECR_PRODUTO}-role-ecr-web-${var.ENV}"
  push     = "${var.push}"
  MUTABLE  = "${var.MUTABLE}"

 # tags = {
 #   Ambiente          = "PROD"
 #   Projeto           = "Liza"
 #   "Tipo de Capital" = "OPEX"
 #   Terraform         = true
 # }

}
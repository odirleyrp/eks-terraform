# SG-eks

Documentação para uso do módulo
## Apontamento

Realizar o clone do repositório ou apontar o source para o repo do git



## Utilização 

Criar o diretório com o nome de projeto ou ambiente, criar os arquivos, provider.tf, vars.tf, backend.tf, output.tf e por fim abaixo o exemplo de arquivo para utilização do módulo cujo o nome pode ser ambiente "BBCE-SANDBOX.tf" :

```

module "SG" {
  source             = "../module/sg"
  name_prefix        = "${var.name_prefix}"
  ENV                = "${var.ENV}"
  requerente         = "${var.requerente}"
  vpc_id             = "${module.vpc.vpc}" #MUDAR PARA O ID
  services_ports     = "${var.services_ports}"
  IPS_VPC_ACCESS_EKS = ["${module.vpc.vpc_cidr_block}"] #MUDAR PARA O ID
}

terraform init 
terraform validate
terraform plan -out exemplo
terraform apply exemplo 

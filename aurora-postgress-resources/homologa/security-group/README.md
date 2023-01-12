# AWS Security Group 
Documentação para uso do módulo

## Apontamento
Realizar o clone do repositório ou apontar o source para o repo do git

## Utilização
Terraform version 0.12 

Criar o diretório com o nome de projeto ou ambiente, criar os arquivos, provider.tf, vars.tf, backend.tf, output.tf e por fim abaixo o exemplo de arquivo para utilização do módulo cujo o nome pode ser ambiente "BBCE-SANDBOX.tf" :  
O diretorio exemplo mostra como deve ser criado a estrutura de arquivos.

```
module "sg" {
  source = "git::https://bbce0256@dev.azure.com/bbce0256/Infra%20as%20Code%20-%20BBCE/_git/security-group"
  name = "sg_exemplo"
  vpc_id = module.vpc.vpc_id
  sg_ingress = {
    "22" = ["0.0.0.0/0"]
    "80" = ["0.0.0.0/0"]
  }
}
module "sg" {
  source = "git::https://bbce0256@dev.azure.com/bbce0256/Infra%20as%20Code%20-%20BBCE/_git/security-group"
  name = "sg_exemplo"
  vpc_id = var.vpc_id
  sg_ingress = {
    "22" = ["0.0.0.0/0"]
    "80" = ["0.0.0.0/0"]
  }
}
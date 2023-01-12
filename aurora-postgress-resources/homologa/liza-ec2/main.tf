
resource "aws_instance" "goliza" {
  ami           = var.amiId
  instance_type = var.typeEc2
  key_name      = var.KEYEC2
  subnet_id           = var.SUBNET_ID
  vpc_security_group_ids      = ["${module.sg-new.id}"]

 
  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }

   tags = {
  app                  = var.app
  modalidade           = var.modalidade
  requerente           = var.requerente
  ambiente             = var.ambiente
  Name                 = var.name
  schedule             = "on"
  }

}



resource "aws_eip" "goliza-eip" {
  vpc              = true
  instance = aws_instance.goliza.id
}


module "sg-new" {
  source = "../security-group"
  name = "sg_ec2_goLiza_hml"
  vpc_id = var.vpc_id

  sg_ingress = {
  "22" = ["10.47.0.0/16", "189.126.204.46/32", "201.43.121.9/32", "179.225.168.131/32", "179.255.168.131/32", "189.18.134.187/32"]

  }

  
  tags = {
    app = "goLiza"
    ambiente = "homologa"
    modalidade = "projeto1"
    requerinte = ""
    Name = "sg-goLiza-hml"
  }

  
}


data aws_route53_zone zone {
  name         = "bbce.tech."
}

module "record-1" {
    source = "git::https://bbce0256@dev.azure.com/bbce0256/Infra%20as%20Code%20-%20BBCE/_git/route53-record"
    route53_zone_id = data.aws_route53_zone.zone.zone_id
    route53_dns_name = "goliza-hml"
    route53_type = "A"
    route53_ttl = "300"
    route53_records = [aws_eip.goliza-eip.public_ip]
    }
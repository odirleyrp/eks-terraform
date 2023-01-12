output ecrname_api {
  value = "${module.ecr-api.ecr-name}"

}


output ecrname_web {
  value = "${module.ecr-web.ecr-name}"

}

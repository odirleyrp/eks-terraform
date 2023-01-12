module user_liza {
  source        = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/iam-user"
  #iam_name      = "user_lisa"
  iam_name = var.name
  force_destroy = true
  project       = var.project
  service       = var.name
}
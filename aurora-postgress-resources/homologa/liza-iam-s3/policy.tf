module "policy-user-liza-ecr" {
  source    = "git::https://bbce0256.visualstudio.com/Infra%20as%20Code%20-%20BBCE/_git/iam-user//policy"
  name      = "policy_user_liza"
  user_name = module.user_liza.name
  policy    = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ecr:PutImageTagMutability",
                "ecr:StartImageScan",
                "ecr:ListTagsForResource",
                "ecr:UploadLayerPart",
                "ecr:BatchDeleteImage",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:CompleteLayerUpload",
                "ecr:TagResource",
                "ecr:DescribeRepositories",
                "ecr:DeleteRepositoryPolicy",
                "ecr:BatchCheckLayerAvailability",
                "ecr:ReplicateImage",
                "ecr:GetLifecyclePolicy",
                "ecr:PutLifecyclePolicy",
                "ecr:DescribeImageScanFindings",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:CreateRepository",
                "ecr:PutImageScanningConfiguration",
                "ecr:GetDownloadUrlForLayer",
                "ecr:DeleteLifecyclePolicy",
                "ecr:PutImage",
                "ecr:UntagResource",
                "ecr:SetRepositoryPolicy",
                "ecr:BatchGetImage",
                "ecr:DescribeImages",
                "ecr:StartLifecyclePolicyPreview",
                "ecr:InitiateLayerUpload",
                "ecr:GetRepositoryPolicy"
            ],
            "Resource": 
              ["arn:aws:ecr:*:993324252386:repository/goliza-api-bbce-shared",
               "arn:aws:ecr:*:993324252386:repository/goliza-web-bbce-shared"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "ecs.amazonaws.com"
                }
            }
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "ecr:GetRegistryPolicy",
                "ec2:CreateTags",
                "ecr:DescribeRegistry",
                "ecr:GetAuthorizationToken",
                "logs:PutLogEvents",
                "ecr:PutRegistryPolicy",
                "ec2:RevokeSecurityGroupIngress",
                "logs:CreateLogStream",
                "iam:CreateServiceLinkedRole",
                "ec2:DeleteSecurityGroup",
                "sts:DecodeAuthorizationMessage",
                "ecr:DeleteRegistryPolicy",
                "ecr:PutReplicationConfiguration"
            ],
            "Resource": "*"
        }

    ]
}
EOF

}
####

resource "aws_iam_role" "role_liza" {
  name = "role-goliza"


  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          "Service": "ecs.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "role-liza"
    Terraform = "true"

  }
}

##
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerServiceRole" {
  role       = aws_iam_role.role_liza.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}




resource "aws_iam_role_policy_attachment" "policy-goLiza" {
  role       = aws_iam_role.role_liza.name
  policy_arn = "arn:aws:iam::993324252386:policy/policy-goLiza"
}
###

resource "aws_iam_user_policy_attachment" "AmazonECS_FullAccess" {
  user       = module.user_liza.name
  policy_arn =  "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_user_policy_attachment" "AWSCodeDeployRoleForECS" {
  user       = module.user_liza.name
  policy_arn =  "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}


resource "aws_iam_user_policy_attachment" "AWSCodeDeployRoleForECSLimited" {
  user       = module.user_liza.name
  policy_arn =  "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECSLimited"
}

resource "aws_iam_user_policy_attachment" "AmazonECSTaskExecutionRolePolicy" {
  user       = module.user_liza.name
  policy_arn =  "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_user_policy_attachment" "AmazonEC2ContainerRegistryFullAccess" {
  user       = module.user_liza.name
  policy_arn =  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}


resource "aws_iam_user_policy_attachment" "ses_policy" {
  user       = module.user_liza.name
  policy_arn =  "arn:aws:iam::993324252386:policy/ses_policy"
}

##


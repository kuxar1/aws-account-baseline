module "ecs_app_plan_tfstate" {
  source      = "./modules/tfstate-access"
  policy_name = "ecs-app-plan-tfstate"
  bucket_arn  = aws_s3_bucket.state_bucket.arn
  state_keys  = ["ecs-app/dev/terraform.tfstate", "ecs-app/prod/terraform.tfstate"]
}

module "ecs_app_dev_tfstate" {
  source      = "./modules/tfstate-access"
  policy_name = "ecs-app-dev-tfstate"
  bucket_arn  = aws_s3_bucket.state_bucket.arn
  state_keys  = ["ecs-app/dev/terraform.tfstate"]
}

module "ecs_app_prod_tfstate" {
  source      = "./modules/tfstate-access"
  policy_name = "ecs-app-prod-tfstate"
  bucket_arn  = aws_s3_bucket.state_bucket.arn
  state_keys  = ["ecs-app/prod/terraform.tfstate"]
}

#### IAM Role Policy Attachments
resource "aws_iam_role_policy_attachment" "gitlab_ecs_app_plan" {
  role       = aws_iam_role.gitlab_ecs_app_plan.name
  policy_arn = module.ecs_app_plan_tfstate.policy_arn
}

resource "aws_iam_role_policy_attachment" "gitlab_ecs_app_dev" {
  role       = aws_iam_role.gitlab_ecs_app_dev.name
  policy_arn = module.ecs_app_dev_tfstate.policy_arn
}

resource "aws_iam_role_policy_attachment" "gitlab_ecs_app_prod" {
  role       = aws_iam_role.gitlab_ecs_app_prod.name
  policy_arn = module.ecs_app_prod_tfstate.policy_arn
}

### IAM Roles
resource "aws_iam_role" "gitlab_ecs_app_plan" {
  name               = "gitlab-ecs-app-plan"
  assume_role_policy = data.aws_iam_policy_document.gitlab_ecs_app_plan.json
}

resource "aws_iam_role" "gitlab_ecs_app_dev" {
  name               = "gitlab-ecs-app-dev"
  assume_role_policy = data.aws_iam_policy_document.gitlab_ecs_app_dev.json
}

resource "aws_iam_role" "gitlab_ecs_app_prod" {
  name               = "gitlab-ecs-app-prod"
  assume_role_policy = data.aws_iam_policy_document.gitlab_ecs_app_prod.json
}

### IAM Trust Policy Documents
data "aws_iam_policy_document" "gitlab_ecs_app_plan" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.gitlab.arn]
    }
    condition {
      test     = "StringLike"
      variable = "${local.gitlab_host}:sub"
      values   = ["project_path:${var.gitlab_project_path}:ref_type:branch:ref:*"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.gitlab_host}:aud"
      values   = [var.gitlab_audience]
    }
  }
}

data "aws_iam_policy_document" "gitlab_ecs_app_dev" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.gitlab.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.gitlab_host}:sub"
      values   = ["project_path:${var.gitlab_project_path}:ref_type:branch:ref:dev"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.gitlab_host}:aud"
      values   = [var.gitlab_audience]
    }
  }
}

data "aws_iam_policy_document" "gitlab_ecs_app_prod" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.gitlab.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.gitlab_host}:sub"
      values   = ["project_path:${var.gitlab_project_path}:ref_type:branch:ref:main"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.gitlab_host}:aud"
      values   = [var.gitlab_audience]
    }
  }
}

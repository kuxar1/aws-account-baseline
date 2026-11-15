module "portfolio_site_tfstate" {
  source      = "./modules/tfstate-access"
  policy_name = "portfolio-site-tfstate"
  bucket_arn  = aws_s3_bucket.state_bucket.arn
  state_keys  = ["portfolio-site/terraform.tfstate"]
}

moved {
  from = aws_iam_policy.portfolio_site_tfstate
  to   = module.portfolio_site_tfstate.aws_iam_policy.this
}

resource "aws_iam_role" "github_portfolio_site_plan" {
  name               = "github-portfolio-site-plan"
  assume_role_policy = data.aws_iam_policy_document.github_portfolio_site_plan_trust.json
}

resource "aws_iam_role" "github_portfolio_site_apply" {
  name               = "github-portfolio-site-apply"
  assume_role_policy = data.aws_iam_policy_document.github_portfolio_site_apply_trust.json
}

# Trusted policy document for the GitHub OIDC role for Terraform plan (pull request) access
data "aws_iam_policy_document" "github_portfolio_site_plan_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["${local.portfolio_site_sub}:pull_request"]
    }
  }
}

# Trusted policy document for the GitHub OIDC role for Terraform apply (production environment) access
data "aws_iam_policy_document" "github_portfolio_site_apply_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["${local.portfolio_site_sub}:environment:production"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "github_portfolio_site_plan" {
  role       = aws_iam_role.github_portfolio_site_plan.name
  policy_arn = module.portfolio_site_tfstate.policy_arn
}

resource "aws_iam_role_policy_attachment" "github_portfolio_site_apply" {
  role       = aws_iam_role.github_portfolio_site_apply.name
  policy_arn = module.portfolio_site_tfstate.policy_arn
}

data "aws_iam_policy_document" "github_portfolio_site_plan_read" {
  statement {
    effect  = "Allow"
    sid     = "ReadSiteBucketConfig"
    actions = ["s3:Get*", "s3:List*"]
    resources = [
      "arn:aws:s3:::devopsing-site-${data.aws_caller_identity.current.account_id}",
    ]
  }
  statement {
    effect    = "Allow"
    sid       = "ReadCloudFront"
    actions   = ["cloudfront:Get*", "cloudfront:List*", "cloudfront:Describe*"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    sid       = "ReadACM"
    actions   = ["acm:Describe*", "acm:List*", "acm:Get*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "github_portfolio_site_apply_write" {
  statement {
    effect  = "Allow"
    sid     = "ManageSiteBucket"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::devopsing-site-${data.aws_caller_identity.current.account_id}/*",
      "arn:aws:s3:::devopsing-site-${data.aws_caller_identity.current.account_id}"
    ]
  }
  statement {
    effect    = "Allow"
    sid       = "ManageCloudFront"
    actions   = ["cloudfront:*"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    sid       = "ManageACM"
    actions   = ["acm:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_portfolio_site_plan" {
  name   = "github-portfolio-site-plan"
  role   = aws_iam_role.github_portfolio_site_plan.id
  policy = data.aws_iam_policy_document.github_portfolio_site_plan_read.json
}

resource "aws_iam_role_policy" "github_portfolio_site_apply" {
  name   = "github-portfolio-site-apply"
  role   = aws_iam_role.github_portfolio_site_apply.id
  policy = data.aws_iam_policy_document.github_portfolio_site_apply_write.json
}

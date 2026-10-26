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

# Managed policy for the GitHub OIDC role to access the S3 bucket for Terraform state
resource "aws_iam_policy" "portfolio_site_tfstate" {
  name   = "portfolio-site-tfstate"
  policy = data.aws_iam_policy_document.portfolio_site_tfstate.json
}

data "aws_iam_policy_document" "portfolio_site_tfstate" {
  statement {
    effect  = "Allow"
    sid     = "ListStatePrefix"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.state_bucket.arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values   = [local.portfolio_state_key]
    }
  }
  statement {
    effect  = "Allow"
    sid     = "ReadWriteState"
    actions = ["s3:GetObject", "s3:PutObject"]
    resources = [
      "${aws_s3_bucket.state_bucket.arn}/${local.portfolio_state_key}",
    ]
  }
  statement {
    effect  = "Allow"
    sid     = "ManageStateLock"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [
      "${aws_s3_bucket.state_bucket.arn}/${local.portfolio_state_key}.tflock",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "github_portfolio_site_plan" {
  role       = aws_iam_role.github_portfolio_site_plan.name
  policy_arn = aws_iam_policy.portfolio_site_tfstate.arn
}

resource "aws_iam_role_policy_attachment" "github_portfolio_site_apply" {
  role       = aws_iam_role.github_portfolio_site_apply.name
  policy_arn = aws_iam_policy.portfolio_site_tfstate.arn
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

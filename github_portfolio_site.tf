locals {
  portfolio_state_key = "portfolio-site/terraform.tfstate"
}

resource "aws_iam_role" "github_portfolio_site" {
  name               = "github-portfolio-site"
  assume_role_policy = data.aws_iam_policy_document.github_portfolio_site_trust.json
}

# Trusted policy document for the GitHub OIDC role to allow GitHub Actions to assume the role
data "aws_iam_policy_document" "github_portfolio_site_trust" {
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
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_owner}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}:*"]
    }
  }
}

# Inline policy document for the GitHub OIDC role to access the S3 bucket for Terraform state
data "aws_iam_policy_document" "github_portfolio_site_permissions" {
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

# Attach inline policy to the role
resource "aws_iam_role_policy" "github_portfolio_site" {
  name   = "github-portfolio-site"
  role   = aws_iam_role.github_portfolio_site.id
  policy = data.aws_iam_policy_document.github_portfolio_site_permissions.json
}

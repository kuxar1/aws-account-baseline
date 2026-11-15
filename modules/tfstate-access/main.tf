# Managed policy granting read/write access to the given Terraform state keys and their lock files
resource "aws_iam_policy" "this" {
  name   = var.policy_name
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    effect  = "Allow"
    sid     = "ListStatePrefix"
    actions = ["s3:ListBucket"]
    resources = [
      var.bucket_arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:prefix"
      values   = var.state_keys
    }
  }
  statement {
    effect    = "Allow"
    sid       = "ReadWriteState"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = [for k in var.state_keys : "${var.bucket_arn}/${k}"]
  }
  statement {
    effect    = "Allow"
    sid       = "ManageStateLock"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [for k in var.state_keys : "${var.bucket_arn}/${k}.tflock"]
  }
}

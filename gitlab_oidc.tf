resource "aws_iam_openid_connect_provider" "gitlab" {
  url = var.gitlab_url
  client_id_list = [
    var.gitlab_audience,
  ]
}

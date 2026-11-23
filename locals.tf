locals {
  portfolio_site_sub = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}"
  gitlab_host        = trimprefix(var.gitlab_url, "https://")
}

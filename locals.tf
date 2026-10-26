locals {
  portfolio_state_key = "portfolio-site/terraform.tfstate"
  portfolio_site_sub  = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}"
}

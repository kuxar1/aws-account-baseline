output "github_portfolio_site_plan_arn" {
  value       = aws_iam_role.github_portfolio_site_plan.arn
  description = "The ARN of the GitHub Portfolio Site plan role (pull request plan)"
}

output "github_portfolio_site_apply_arn" {
  value       = aws_iam_role.github_portfolio_site_apply.arn
  description = "The ARN of the GitHub Portfolio Site apply role (production environment)"
}

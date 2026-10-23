output "github_portfolio_site_arn" {
  value       = aws_iam_role.github_portfolio_site.arn
  description = "The ARN of the GitHub Portfolio Site role"
}

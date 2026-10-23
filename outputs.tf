output "github_oidc_role_arn" {
  value       = aws_iam_role.github_portfolio_site.arn
  description = "The ARN of the GitHub OIDC role"
}

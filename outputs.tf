### Portfolio Site Project Outputs ###
output "github_portfolio_site_plan_arn" {
  value       = aws_iam_role.github_portfolio_site_plan.arn
  description = "The ARN of the GitHub Portfolio Site plan role (pull request plan)"
}

output "github_portfolio_site_apply_arn" {
  value       = aws_iam_role.github_portfolio_site_apply.arn
  description = "The ARN of the GitHub Portfolio Site apply role (production environment)"
}

### ECS App Project Outputs ###
output "gitlab_ecs_app_plan_arn" {
  value       = aws_iam_role.gitlab_ecs_app_plan.arn
  description = "The ARN of the GitLab ECS App plan role (merge request plan)"
}

output "gitlab_ecs_app_dev_arn" {
  value       = aws_iam_role.gitlab_ecs_app_dev.arn
  description = "The ARN of the GitLab ECS App dev role (development environment)"
}

output "gitlab_ecs_app_prod_arn" {
  value       = aws_iam_role.gitlab_ecs_app_prod.arn
  description = "The ARN of the GitLab ECS App prod role (production environment)"
}

### Portfolio Site Project Variables ###
variable "github_owner" {
  type        = string
  default     = "kuxar1"
  description = "GitHub owner for the repository"
}

variable "github_repo" {
  type        = string
  default     = "portfolio-site"
  description = "GitHub repository name"
}

variable "github_owner_id" {
  type        = string
  default     = "79282334"
  description = "GitHub owner ID for the repository"
}

variable "github_repo_id" {
  type        = string
  default     = "1430942197"
  description = "GitHub repository ID for the repository"
}

### ECS App Project Variables ###
variable "gitlab_url" {
  type        = string
  default     = "https://gitlab.com"
  description = "GitLab URL for the repository"
}

variable "gitlab_audience" {
  type        = string
  default     = "https://gitlab.com"
  description = "GitLab audience for the repository"
}

variable "gitlab_project_path" {
  type        = string
  default     = "kuxar1/ecs-app"
  description = "GitLab project path for the repository"
}


variable "policy_name" {
  type        = string
  description = "Name of the IAM policy"
}

variable "bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket that holds Terraform state"
}

variable "state_keys" {
  type        = list(string)
  description = "State object keys the policy grants access to, e.g. [\"ecs-app/dev/terraform.tfstate\"]"
  validation {
    condition     = length(var.state_keys) > 0
    error_message = "At least one state key must be provided"
  }
}

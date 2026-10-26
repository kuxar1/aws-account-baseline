resource "aws_accessanalyzer_analyzer" "account" {
  analyzer_name = "account-external-access"
  type          = "ACCOUNT"
}

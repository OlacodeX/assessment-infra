resource "aws_cloudwatch_log_group" "backend" {

  name = "/assessment/backend"

  retention_in_days = 7
}
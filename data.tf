data "aws_caller_identity" "identity" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_kms_key" "secrets" {
  for_each = var.kms_key_arn != null ? toset(["this"]) : toset([])

  key_id = var.kms_key_arn
}

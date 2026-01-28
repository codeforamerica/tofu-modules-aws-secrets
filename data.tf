data "aws_caller_identity" "identity" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_kms_key" "secrets" {
  for_each = var.create_kms_key ? toset([]) : toset(["this"])

  key_id = var.kms_key_arn
}

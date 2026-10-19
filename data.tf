data "aws_caller_identity" "identity" {}

data "aws_partition" "current" {}

data "aws_region" "current" {
  lifecycle {
    postcondition {
      condition     = !var.replication.enabled || var.create_kms_key || var.replication.kms_arn != null
      error_message = "When create_kms_key is false, replication.kms_arn must be provided."
    }

    postcondition {
      condition     = !var.replication.enabled || var.replication.region != self.region
      error_message = "replication.region must be different from the current region."
    }
  }
}

data "aws_kms_key" "secrets" {
  for_each = var.create_kms_key ? toset([]) : toset(["this"])

  key_id = var.kms_key_arn
}

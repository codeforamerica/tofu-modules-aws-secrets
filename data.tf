data "aws_caller_identity" "identity" {}

data "aws_partition" "current" {}

data "aws_region" "current" {
  lifecycle {
    postcondition {
      condition     = !var.enable_replication || var.create_kms_key
      error_message = "enable_replication requires create_kms_key to be true."
    }

    postcondition {
      condition     = !var.enable_replication || var.replica_region != self.region
      error_message = "replica_region must be different from the current region."
    }
  }
}

data "aws_kms_key" "secrets" {
  for_each = var.create_kms_key ? toset([]) : toset(["this"])

  key_id = var.kms_key_arn
}

resource "aws_kms_key" "secrets" {
  for_each = var.create_kms_key ? toset(["this"]) : toset([])

  description             = "Secrets encryption key for ${var.project} ${var.environment}"
  deletion_window_in_days = var.key_recovery_period
  enable_key_rotation     = true
  multi_region            = var.enable_replication
  policy = jsonencode(yamldecode(templatefile("${path.module}/templates/key-policy.yaml.tftpl", {
    account_id : data.aws_caller_identity.identity.account_id,
    partition : data.aws_partition.current.partition,
    region : data.aws_region.current.region,
  })))

  tags = var.tags

  # Keep the old key enabled until the secrets have moved to the new one, so
  # that Secrets Manager can decrypt and re-encrypt the existing versions.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_kms_alias" "secrets" {
  for_each = var.create_kms_key ? toset(["this"]) : toset([])

  name          = "alias/${var.project}/${var.environment}/${var.service != "" ? "${var.service}/" : ""}secrets"
  target_key_id = aws_kms_key.secrets["this"].id
}

# Create a replica of the secrets key in the replica region, if configured. The
# policy is rendered for the replica region so that Secrets Manager can use the
# key there.
resource "aws_kms_replica_key" "secrets" {
  for_each = var.create_kms_key && var.enable_replication ? toset(["this"]) : toset([])

  region                  = var.replica_region
  description             = "Multi-Region replica of the secrets encryption key for ${var.project} ${var.environment}"
  deletion_window_in_days = var.key_recovery_period
  primary_key_arn         = aws_kms_key.secrets["this"].arn
  policy = jsonencode(yamldecode(templatefile("${path.module}/templates/key-policy.yaml.tftpl", {
    account_id : data.aws_caller_identity.identity.account_id,
    partition : data.aws_partition.current.partition,
    region : var.replica_region,
  })))

  tags = var.tags
}

resource "aws_kms_alias" "secrets_replica" {
  for_each = var.create_kms_key && var.enable_replication ? toset(["this"]) : toset([])

  region        = var.replica_region
  name          = "alias/${var.project}/${var.environment}/${var.service != "" ? "${var.service}/" : ""}secrets"
  target_key_id = aws_kms_replica_key.secrets["this"].id
}

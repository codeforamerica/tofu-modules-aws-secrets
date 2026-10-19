resource "aws_kms_key" "secrets" {
  for_each = var.create_kms_key ? toset(["this"]) : toset([])

  description             = "Secrets encryption key for ${var.project} ${var.environment}"
  deletion_window_in_days = var.key_recovery_period
  enable_key_rotation     = true
  multi_region            = var.kms_multi_region
  policy = jsonencode(yamldecode(templatefile("${path.module}/templates/key-policy.yaml.tftpl", {
    account_id : data.aws_caller_identity.identity.account_id,
    partition : data.aws_partition.current.partition,
    region : data.aws_region.current.region,
  })))

  tags = var.tags

  lifecycle {
    # The multi-region setting can only be configured at creation. Attempting to
    # change it later would cause the resource to be recreated which can result
    # in data lock out.
    ignore_changes = [multi_region]
  }
}

resource "aws_kms_alias" "secrets" {
  for_each = var.create_kms_key ? toset(["this"]) : toset([])

  name          = "alias/${var.project}/${var.environment}/${var.service != "" ? "${var.service}/" : ""}secrets"
  target_key_id = aws_kms_key.secrets["this"].id
}

# The policy for the replica region's key is rendered for that region so that
# Secrets Manager can use the key there.
resource "aws_kms_replica_key" "secrets" {
  for_each = local.replica_kms_source == "replica" ? toset(["this"]) : toset([])

  region                  = local.replica_region
  description             = "Multi-Region replica of the secrets encryption key for ${var.project} ${var.environment}"
  deletion_window_in_days = var.key_recovery_period
  primary_key_arn         = aws_kms_key.secrets["this"].arn
  policy = jsonencode(yamldecode(templatefile("${path.module}/templates/key-policy.yaml.tftpl", {
    account_id : data.aws_caller_identity.identity.account_id,
    partition : data.aws_partition.current.partition,
    region : local.replica_region,
  })))

  tags = var.tags
}

# A single-region primary key can't be replicated, so the replicas get their own
# key in the replica region instead.
resource "aws_kms_key" "replica" {
  for_each = local.replica_kms_source == "create" ? toset(["this"]) : toset([])

  region                  = local.replica_region
  description             = "Secrets encryption key for ${var.project} ${var.environment} replicas"
  deletion_window_in_days = var.key_recovery_period
  enable_key_rotation     = true
  policy = jsonencode(yamldecode(templatefile("${path.module}/templates/key-policy.yaml.tftpl", {
    account_id : data.aws_caller_identity.identity.account_id,
    partition : data.aws_partition.current.partition,
    region : local.replica_region,
  })))

  tags = var.tags
}

resource "aws_kms_alias" "replica" {
  for_each = contains(["replica", "create"], local.replica_kms_source) ? toset(["this"]) : toset([])

  region        = local.replica_region
  name          = "alias/${var.project}/${var.environment}/${var.service != "" ? "${var.service}/" : ""}secrets"
  target_key_id = local.replica_kms_key_arn
}

check "replica_kms_multi_region" {
  assert {
    condition     = !(local.replica_kms_source == "create" && var.kms_multi_region)
    error_message = <<-EOT
      The secrets KMS key is single-region, so it can't be replicated. A
      separate single-region key is being created in ${local.replica_region}
      for the replicas instead.
      EOT
  }
}

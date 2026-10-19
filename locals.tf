locals {
  kms_key_arn = var.create_kms_key ? aws_kms_key.secrets["this"].arn : var.kms_key_arn
  kms_key_id  = var.create_kms_key ? aws_kms_key.secrets["this"].id : data.aws_kms_key.secrets["this"].id

  # Default to us-west-2, or us-east-1 if the secrets are already out west.
  replica_region = coalesce(var.replication.region, startswith(data.aws_region.current.region, "us-west") ? "us-east-1" : "us-west-2")

  # Where the replicas' key comes from. A caller-provided key always wins.
  # Otherwise a module-created primary key is replicated when it's
  # multi-Region, and a new key is created when it isn't. The key's actual
  # multi_region attribute is used, since kms_multi_region is ignored after the
  # key is created.
  replica_kms_source = (
    !var.replication.enabled ? "none"
    : var.replication.kms_arn != null ? "provided"
    : !var.create_kms_key ? "none"
    : aws_kms_key.secrets["this"].multi_region ? "replica"
    : "create"
  )
  replica_kms_key_arn = (
    local.replica_kms_source == "provided" ? var.replication.kms_arn
    : local.replica_kms_source == "replica" ? aws_kms_replica_key.secrets["this"].arn
    : local.replica_kms_source == "create" ? aws_kms_key.replica["this"].arn
    : null
  )
}

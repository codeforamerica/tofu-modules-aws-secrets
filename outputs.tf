output "kms_key_alias" {
  description = <<-EOT
    Alias for the created KMS key. If `kms_key_arn`is provided, this will be
    `null`.
    EOT
  value       = var.create_kms_key ? aws_kms_alias.secrets["this"].name : null
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption."
  value       = local.kms_key_arn
}

output "kms_replica_key_arn" {
  description = "ARN of the replica KMS key. If `enable_replication` is `false`, this will be `null`."
  value       = var.create_kms_key && var.enable_replication ? aws_kms_replica_key.secrets["this"].arn : null
}

output "secrets" {
  description = "A map of created secrets."
  value       = module.secrets_manager
}

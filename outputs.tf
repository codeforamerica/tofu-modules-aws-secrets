output "kms_key_alias" {
  description = <<-EOT
    Alias for the created KMS key. If `kms_key_arn`is provided, this will be
    `null`.
    EOT
  value       = var.kms_key_arn == null ? aws_kms_alias.secrets["this"].name : null
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption."
  value       = local.kms_key_arn
}

output "secrets" {
  description = "A map of created secrets."
  value       = module.secrets_manager
}

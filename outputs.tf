output "kms_key_alias" {
  description = "Alias for of the KMS key used for encryption."
  value = aws_kms_alias.secrets.name
}

output "kms_key_arn" {
  description = "ARN for of the KMS key used for encryption."
  value = aws_kms_key.secrets.arn
}

output "secrets" {
  description = "A map of created secrets."
  value = module.secrets_manager
}

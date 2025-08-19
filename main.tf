module "secrets_manager" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "~> 2.0"

  for_each = var.secrets

  name = (coalesce(each.value.add_suffix, var.add_suffix)
    ? null
    : coalesce(each.value.name, join("/", compact([var.project, var.environment, var.service, each.key])))
  )
  name_prefix = (coalesce(each.value.add_suffix, var.add_suffix)
    ? "${coalesce(each.value.name, join("/", compact([var.project, var.environment, var.service, each.key])))}-"
    : null
  )
  create_random_password  = each.value.create_random_password
  description             = each.value.description
  recovery_window_in_days = each.value.recovery_window
  kms_key_id              = aws_kms_alias.secrets.id
  secret_string           = each.value.start_value

  ignore_secret_changes = true

  tags = var.tags
}

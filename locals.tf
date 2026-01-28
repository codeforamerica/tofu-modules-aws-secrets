locals {
  kms_key_arn = var.create_kms_key ? aws_kms_key.secrets["this"].arn : var.kms_key_arn
  kms_key_id  = var.create_kms_key ? aws_kms_key.secrets["this"].id : data.aws_kms_key.secrets["this"].id
}

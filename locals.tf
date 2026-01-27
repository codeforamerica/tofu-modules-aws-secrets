locals {
  kms_key_arn = var.kms_key_arn != null ? var.kms_key_arn : aws_kms_key.secrets["this"].arn
  kms_key_id  = var.kms_key_arn != null ? data.aws_kms_key.secrets["this"].id : aws_kms_key.secrets["this"].id
}

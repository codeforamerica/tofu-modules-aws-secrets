moved {
  from = aws_kms_key.secrets
  to   = aws_kms_key.secrets["this"]
}

moved {
  from = aws_kms_alias.secrets
  to   = aws_kms_alias.secrets["this"]
}

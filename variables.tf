variable "add_suffix" {
  type        = bool
  description = "Apply a random suffix to the secret name. Useful when secrets may need to be replaced, but makes identify secrets by name alone more difficult."
  default     = true
}

variable "create_kms_key" {
  type        = bool
  description = <<-EOT
    Whether to create a new KMS key for encrypting secrets. If set to `false`,
    `kms_key_arn` must be provided.
    EOT
  default     = true
}

variable "environment" {
  type        = string
  description = "Environment for the deployment."
  default     = "dev"
}

variable "key_recovery_period" {
  type        = number
  default     = 30
  description = <<-EOT
    Recovery period for deleted KMS key, in days. Must be between 7 and 30, or 0
    to disable recovery. Only used if `create_kms_key` is set to `true`.
    EOT

  validation {
    condition     = var.key_recovery_period == 0 || (var.key_recovery_period > 6 && var.key_recovery_period < 31)
    error_message = "Recovery period must be between 7 and 30, or 0 to disable recovery."
  }
}

variable "kms_key_arn" {
  type        = string
  description = <<-EOT
    ARN for an existing KMS key to use for encryption. Required if
    `create_kms_key` is set to `false`; ignored otherwise.
    EOT
  default     = null
}

variable "project" {
  type        = string
  description = "Project that these resources are supporting."
}

# TODO: Support rotation.
variable "secrets" {
  type = map(object({
    add_suffix             = optional(bool, null)
    create_random_password = optional(bool, false)
    description            = string
    name                   = optional(string, null)
    recovery_window        = optional(number, 30)
    start_value            = optional(string, "{}")
  }))

  description = "List of VPC peering connections."
  default     = {}
}

variable "service" {
  type        = string
  description = "Optional service that these resources are supporting. Example: 'api', 'web', 'worker'"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default     = {}
}

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
    Recovery period for deleted KMS keys in days. Must be between 7 and 30. Only
    used if `create_kms_key` is set to `true`.
    EOT

  validation {
    condition     = var.key_recovery_period > 6 && var.key_recovery_period < 31
    error_message = "Key recovery period must be between 7 and 30."
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

variable "kms_multi_region" {
  type        = bool
  description = <<-EOT
    Whether the KMS key is created as multi-Region. Only used if
    `create_kms_key` is set to `true`. This setting can only be configured at
    creation; changing this on an existing key will have no effect.
    EOT
  default     = true
}

variable "project" {
  type        = string
  description = "Project that these resources are supporting."
}

variable "recovery_window" {
  type        = number
  default     = 30
  description = <<-EOT
    Recovery window for deleted secrets, in days. Must be between 7 and 30, or 0
    to disable recovery when the secret is deleted. This value can be overridden
    for each secret by setting the `recovery_window` for the secret.
    EOT

  validation {
    condition     = var.recovery_window == 0 || (var.recovery_window > 6 && var.recovery_window < 31)
    error_message = "Recovery window must be between 7 and 30, or 0 to disable recovery."
  }
}

variable "replication" {
  type = object({
    enabled = optional(bool, false)
    kms_arn = optional(string, null)
    region  = optional(string, null)
  })
  description = <<-EOT
    Cross-region replication settings for the secrets.

    - `enabled`: Whether to replicate the secrets to another region.
    - `kms_arn`: ARN of an existing KMS key in the replica region to encrypt the
      replicas. Required when `create_kms_key` is `false`, and can't be set
      otherwise. When the module creates the key, it replicates that key if
      it's multi-Region, or creates a new key in the replica region if it isn't.
    - `region`: Region to replicate to. Defaults to `us-west-2`, or `us-east-1`
      if the secrets are in a `us-west-*` region.
    EOT
  default     = {}

  validation {
    condition = (
      var.replication.region == null
      || contains(["us-east-1", "us-east-2", "us-west-1", "us-west-2"], var.replication.region)
    )
    error_message = "replication.region must be one of us-east-1, us-east-2, us-west-1, or us-west-2."
  }
}

# TODO: Support rotation.
variable "secrets" {
  type = map(object({
    add_suffix             = optional(bool, null)
    create_random_password = optional(bool, false)
    description            = string
    name                   = optional(string, null)
    recovery_window        = optional(number, null)
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

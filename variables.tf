// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

# -----------------------------------------------------------------------------
# Required
# -----------------------------------------------------------------------------

variable "application_id" {
  description = "AppConfig application ID."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{4,7}$", var.application_id))
    error_message = "application_id must match ^[a-z0-9]{4,7}$."
  }
}

variable "configuration_profile_id" {
  description = "AppConfig configuration profile ID."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{4,7}$", var.configuration_profile_id))
    error_message = "configuration_profile_id must match ^[a-z0-9]{4,7}$."
  }
}

variable "configuration_version" {
  description = "Configuration version to deploy. Must be 1 to 1024 characters."
  type        = string

  validation {
    condition     = length(var.configuration_version) >= 1 && length(var.configuration_version) <= 1024
    error_message = "configuration_version must be between 1 and 1024 characters."
  }
}
variable "deployment_strategy_id" {
  description = "Deployment strategy ID or predefined AppConfig strategy ID."
  type        = string

  validation {
    condition     = can(regex("(^[a-z0-9]{4,7}$|^AppConfig\\.[A-Za-z0-9]{9,40}$)", var.deployment_strategy_id))
    error_message = "deployment_strategy_id must be an AppConfig ID or predefined AppConfig strategy ID."
  }
}
variable "environment_id" {
  description = "AppConfig environment ID."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{4,7}$", var.environment_id))
    error_message = "environment_id must match ^[a-z0-9]{4,7}$."
  }
}

# -----------------------------------------------------------------------------
# Optional
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the AppConfig deployment. Must be at most 1024 characters."
  type        = string
  default     = null

  validation {
    condition     = var.description == null ? true : length(var.description) <= 1024
    error_message = "Description must be at most 1024 characters."
  }
}

variable "kms_key_identifier" {
  description = "KMS key identifier used to encrypt the configuration data."
  type        = string
  default     = null
}

variable "region" {
  description = "AWS Region where this resource is managed. Defaults to the provider-configured Region."
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to assign to the resource. Up to 50 tags are allowed; tag keys must be 1 to 128 characters and values must be at most 256 characters."
  type        = map(string)
  default     = {}

  validation {
    condition = length(var.tags) <= 50 && alltrue([
      for key, value in var.tags : length(key) >= 1 && length(key) <= 128 && length(value) <= 256
    ])
    error_message = "Tags must contain at most 50 entries. Tag keys must be 1 to 128 characters and values must be at most 256 characters."
  }
}

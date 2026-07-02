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

variable "logical_product_family" {
  description = "Logical product family for generated resource names."
  type        = string
}

variable "logical_product_service" {
  description = "Logical product service for generated resource names."
  type        = string
}

variable "class_env" {
  description = "Environment class for generated resource names."
  type        = string
}

variable "instance_env" {
  description = "Environment instance number for generated resource names."
  type        = number
}

variable "instance_resource" {
  description = "Resource instance number for generated resource names."
  type        = number
}

variable "resource_names_map" {
  description = "Resource name configuration keyed by resource role."
  type = map(object({
    name       = string
    max_length = number
  }))
}

variable "tags" {
  description = "Map of tags to assign to resources."
  type        = map(string)
  default     = {}
}
variable "description" {
  description = "Deployment description."
  type        = string
  default     = "Example AppConfig deployment."
}

variable "feature_flag_content" {
  description = <<-EOT
    Hosted feature flag document. This is the source of truth for configuration
    content; changes here create a new hosted configuration version (see the
    terraform_data and lifecycle comments in main.tf).
  EOT
  type = object({
    version = string
    flags = map(object({
      name = string
    }))
    values = map(object({
      enabled = bool
    }))
  })
  default = {
    version = "1"
    flags = {
      example = {
        name = "example"
      }
    }
    values = {
      example = {
        enabled = true
      }
    }
  }
}

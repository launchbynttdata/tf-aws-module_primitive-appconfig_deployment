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

output "id" {
  description = "The deployment ID."
  value       = aws_appconfig_deployment.deployment.id
}

output "arn" {
  description = "The ARN of the deployment."
  value       = aws_appconfig_deployment.deployment.arn
}

output "deployment_number" {
  description = "The deployment number."
  value       = aws_appconfig_deployment.deployment.deployment_number
}

output "state" {
  description = "The deployment state."
  value       = aws_appconfig_deployment.deployment.state
}

output "application_id" {
  description = "The application ID."
  value       = aws_appconfig_deployment.deployment.application_id
}

output "environment_id" {
  description = "The environment ID."
  value       = aws_appconfig_deployment.deployment.environment_id
}

output "configuration_profile_id" {
  description = "The configuration profile ID."
  value       = aws_appconfig_deployment.deployment.configuration_profile_id
}

output "configuration_version" {
  description = "The configuration version."
  value       = aws_appconfig_deployment.deployment.configuration_version
}

output "deployment_strategy_id" {
  description = "The deployment strategy ID."
  value       = aws_appconfig_deployment.deployment.deployment_strategy_id
}

output "description" {
  description = "The deployment description."
  value       = aws_appconfig_deployment.deployment.description
}

output "kms_key_identifier" {
  description = "The KMS key identifier used to encrypt configuration data."
  value       = aws_appconfig_deployment.deployment.kms_key_identifier
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt configuration data."
  value       = aws_appconfig_deployment.deployment.kms_key_arn
}

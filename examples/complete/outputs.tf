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
  value       = module.deployment.id
}
output "arn" {
  description = "The ARN of the deployment."
  value       = module.deployment.arn
}
output "deployment_number" {
  description = "The deployment number."
  value       = module.deployment.deployment_number
}
output "state" {
  description = "The deployment state."
  value       = module.deployment.state
}
output "application_id" {
  description = "The application ID."
  value       = module.deployment.application_id
}
output "environment_id" {
  description = "The environment ID."
  value       = module.deployment.environment_id
}
output "configuration_profile_id" {
  description = "The configuration profile ID."
  value       = module.deployment.configuration_profile_id
}
output "configuration_version" {
  description = "The configuration version."
  value       = module.deployment.configuration_version
}
output "expected_configuration_version" {
  description = "Expected configuration version."
  value       = tostring(aws_appconfig_hosted_configuration_version.example.version_number)
}

output "region" {
  description = "The AWS Region where the example resources are deployed."
  value       = data.aws_region.current.region
}

output "expected_kms_key_arn" {
  description = "Expected KMS key ARN."
  value       = aws_kms_key.appconfig.arn
}

output "expected_kms_key_identifier" {
  description = "Expected KMS key identifier."
  value       = aws_kms_key.appconfig.arn
}

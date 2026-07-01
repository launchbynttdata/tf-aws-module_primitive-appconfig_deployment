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

resource "aws_appconfig_deployment" "deployment" {
  application_id           = var.application_id
  configuration_profile_id = var.configuration_profile_id
  configuration_version    = var.configuration_version
  deployment_strategy_id   = var.deployment_strategy_id
  environment_id           = var.environment_id
  description              = var.description
  kms_key_identifier       = var.kms_key_identifier
  region                   = var.region
  tags                     = var.tags
}

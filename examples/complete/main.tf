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

data "aws_region" "current" {}


module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  cloud_resource_type     = each.value.name
  maximum_length          = each.value.max_length

  region = join("", split("-", data.aws_region.current.region))
}

resource "aws_appconfig_application" "example" {
  name = module.resource_names["application"].standard
  tags = var.tags
}

resource "aws_appconfig_environment" "example" {
  application_id = aws_appconfig_application.example.id
  name           = module.resource_names["environment"].standard
  tags           = var.tags
}

resource "aws_appconfig_configuration_profile" "example" {
  application_id = aws_appconfig_application.example.id
  name           = module.resource_names["configuration_profile"].standard
  location_uri   = "hosted"
  type           = "AWS.AppConfig.FeatureFlags"
  tags           = var.tags
}

resource "aws_appconfig_hosted_configuration_version" "example" {
  application_id           = aws_appconfig_application.example.id
  configuration_profile_id = aws_appconfig_configuration_profile.example.configuration_profile_id
  content                  = var.content
  content_type             = "application/json"
}

resource "aws_appconfig_deployment_strategy" "example" {
  name                           = module.resource_names["deployment_strategy"].standard
  deployment_duration_in_minutes = 0
  growth_factor                  = 100
  growth_type                    = "LINEAR"
  replicate_to                   = "NONE"
  tags                           = var.tags
}

module "deployment" {
  source = "../.."

  application_id           = aws_appconfig_application.example.id
  configuration_profile_id = aws_appconfig_configuration_profile.example.configuration_profile_id
  configuration_version    = aws_appconfig_hosted_configuration_version.example.version_number
  deployment_strategy_id   = aws_appconfig_deployment_strategy.example.id
  environment_id           = aws_appconfig_environment.example.environment_id
  description              = var.description
  tags                     = var.tags
}

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

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "appconfig_kms" {
  statement {
    sid     = "EnableAccountAdministration"
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }

  statement {
    sid    = "AllowAppConfigUse"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
    ]
    principals {
      type        = "Service"
      identifiers = ["appconfig.amazonaws.com"]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "appconfig" {
  description         = "KMS key for AppConfig hosted configuration data"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.appconfig_kms.json
  tags                = merge(var.tags, { Name = module.resource_names["kms_key"].standard })
}



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
  application_id     = aws_appconfig_application.example.id
  name               = module.resource_names["configuration_profile"].standard
  location_uri       = "hosted"
  type               = "AWS.AppConfig.FeatureFlags"
  kms_key_identifier = aws_kms_key.appconfig.arn
  tags               = var.tags
}

# AppConfig FeatureFlags content permadiff
#
# Problem: AWS.AppConfig.FeatureFlags profiles are not byte-stable in Terraform.
# On create, AppConfig injects _createdAt and _updatedAt into the JSON document.
# On every refresh, Terraform compares submitted content with what AWS returns;
# they differ even when the flags themselves are unchanged, so a plain
# aws_appconfig_hosted_configuration_version plans a destroy/create on every run.
# That cascades into aws_appconfig_deployment because configuration_version changes.
#
# Approach: This is not the usual "set content and let drift detection work" pattern.
# - ignore_changes on content suppresses the false-positive AWS metadata drift.
# - terraform_data tracks var.feature_flag_content as the source of truth.
# - replace_triggered_by ties replacement to intentional content changes only.
#
# Operations:
# - No-op plans stay empty (idempotent applies).
# - Changing feature_flag_content creates a new hosted configuration version and,
#   via module.deployment below, a new deployment.
# - Plans will not show a content diff (content is sensitive and ignored on read);
#   look for terraform_data and hosted_configuration_version replacement instead.
# - Content changes made outside Terraform (console, CLI) are not reconciled;
#   subsequent applies will not roll them back.
resource "terraform_data" "example_feature_flag_content" {
  input = var.feature_flag_content
}

resource "aws_appconfig_hosted_configuration_version" "example" {
  application_id           = aws_appconfig_application.example.id
  configuration_profile_id = aws_appconfig_configuration_profile.example.configuration_profile_id
  content                  = jsonencode(var.feature_flag_content)
  content_type             = "application/json"

  lifecycle {
    ignore_changes = [content]

    replace_triggered_by = [
      terraform_data.example_feature_flag_content,
    ]
  }
}

# Instant deployment keeps the lifecycle test fast while still exercising StartDeployment.
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
  kms_key_identifier       = aws_kms_key.appconfig.arn
  description              = var.description
  tags                     = var.tags
}

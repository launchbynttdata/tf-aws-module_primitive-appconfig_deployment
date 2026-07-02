# Complete Example

This example creates a complete AppConfig deployment deployment with the dependencies required to exercise the primitive module.

## Usage

```hcl
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
  application_id = aws_appconfig_application.example.id
  name           = module.resource_names["configuration_profile"].standard
  location_uri   = "hosted"
  type               = "AWS.AppConfig.FeatureFlags"
  kms_key_identifier = aws_kms_key.appconfig.arn
  tags           = var.tags
}

resource "aws_appconfig_hosted_configuration_version" "example" {
  application_id           = aws_appconfig_application.example.id
  configuration_profile_id = aws_appconfig_configuration_profile.example.configuration_profile_id
  content                  = var.content
  content_type             = "application/json"
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
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.100, < 7.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_deployment"></a> [deployment](#module\_deployment) | ../.. | n/a |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_appconfig_application.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_application) | resource |
| [aws_appconfig_configuration_profile.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_configuration_profile) | resource |
| [aws_appconfig_deployment_strategy.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment_strategy) | resource |
| [aws_appconfig_environment.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_environment) | resource |
| [aws_appconfig_hosted_configuration_version.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_hosted_configuration_version) | resource |
| [aws_kms_key.appconfig](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.appconfig_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Environment class for generated resource names. | `string` | n/a | yes |
| <a name="input_content"></a> [content](#input\_content) | Hosted feature flag document. | `string` | `"{\n  \"version\": \"1\",\n  \"flags\": {\n    \"example\": {\n      \"name\": \"example\"\n    }\n  },\n  \"values\": {\n    \"example\": {\n      \"enabled\": true\n    }\n  }\n}\n"` | no |
| <a name="input_description"></a> [description](#input\_description) | Deployment description. | `string` | `"Example AppConfig deployment."` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Environment instance number for generated resource names. | `number` | n/a | yes |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Resource instance number for generated resource names. | `number` | n/a | yes |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family for generated resource names. | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service for generated resource names. | `string` | n/a | yes |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Resource name configuration keyed by resource role. | <pre>map(object({<br/>    name       = string<br/>    max_length = number<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | The application ID. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the deployment. |
| <a name="output_configuration_profile_id"></a> [configuration\_profile\_id](#output\_configuration\_profile\_id) | The configuration profile ID. |
| <a name="output_configuration_version"></a> [configuration\_version](#output\_configuration\_version) | The configuration version. |
| <a name="output_deployment_number"></a> [deployment\_number](#output\_deployment\_number) | The deployment number. |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | The environment ID. |
| <a name="output_expected_configuration_version"></a> [expected\_configuration\_version](#output\_expected\_configuration\_version) | Expected configuration version. |
| <a name="output_expected_kms_key_arn"></a> [expected\_kms\_key\_arn](#output\_expected\_kms\_key\_arn) | Expected KMS key ARN. |
| <a name="output_expected_kms_key_identifier"></a> [expected\_kms\_key\_identifier](#output\_expected\_kms\_key\_identifier) | Expected KMS key identifier. |
| <a name="output_id"></a> [id](#output\_id) | The deployment ID. |
| <a name="output_region"></a> [region](#output\_region) | The AWS Region where the example resources are deployed. |
| <a name="output_state"></a> [state](#output\_state) | The deployment state. |
<!-- END_TF_DOCS -->

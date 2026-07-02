# Terraform AWS Module: AppConfig Deployment (Primitive)

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This primitive module manages one AWS AppConfig deployment resource and exposes the commonly used Terraform provider arguments for composition by collection and reference architecture modules.

## Usage

```hcl
module "example" {
  source = "terraform.registry.launch.nttdata.com/module_primitive/appconfig_deployment/aws"

  # See examples/complete for a deployable configuration.
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appconfig_deployment.deployment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_deployment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | AppConfig application ID. | `string` | n/a | yes |
| <a name="input_configuration_profile_id"></a> [configuration\_profile\_id](#input\_configuration\_profile\_id) | AppConfig configuration profile ID. | `string` | n/a | yes |
| <a name="input_configuration_version"></a> [configuration\_version](#input\_configuration\_version) | Configuration version to deploy. Must be 1 to 1024 characters. | `string` | n/a | yes |
| <a name="input_deployment_strategy_id"></a> [deployment\_strategy\_id](#input\_deployment\_strategy\_id) | Deployment strategy ID or predefined AppConfig strategy ID. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the AppConfig deployment. Must be at most 1024 characters. | `string` | `null` | no |
| <a name="input_environment_id"></a> [environment\_id](#input\_environment\_id) | AppConfig environment ID. | `string` | n/a | yes |
| <a name="input_kms_key_identifier"></a> [kms\_key\_identifier](#input\_kms\_key\_identifier) | KMS key identifier used to encrypt the configuration data. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region where this resource is managed. Defaults to the provider-configured Region. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the resource. Up to 50 tags are allowed; tag keys must be 1 to 128 characters and values must be at most 256 characters. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | The application ID. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the deployment. |
| <a name="output_configuration_profile_id"></a> [configuration\_profile\_id](#output\_configuration\_profile\_id) | The configuration profile ID. |
| <a name="output_configuration_version"></a> [configuration\_version](#output\_configuration\_version) | The configuration version. |
| <a name="output_deployment_number"></a> [deployment\_number](#output\_deployment\_number) | The deployment number. |
| <a name="output_deployment_strategy_id"></a> [deployment\_strategy\_id](#output\_deployment\_strategy\_id) | The deployment strategy ID. |
| <a name="output_description"></a> [description](#output\_description) | The deployment description. |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | The environment ID. |
| <a name="output_id"></a> [id](#output\_id) | The deployment ID. |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | The ARN of the KMS key used to encrypt configuration data. |
| <a name="output_kms_key_identifier"></a> [kms\_key\_identifier](#output\_kms\_key\_identifier) | The KMS key identifier used to encrypt configuration data. |
| <a name="output_state"></a> [state](#output\_state) | The deployment state. |
<!-- END_TF_DOCS -->

## Module Development

### Pre-Requisites

The following commands should be available on your system:

- `asdf` or `mise`
- `make`
- `python3` (for pre-commit)

Additionally, your `git` user and email must be configured. Run the `make configure` command from the root of the repository to ensure that you meet these requirements.

### Pre-Commit hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to Terraform and Golang, as well as some common linting tasks. These will be configured for you when you run `make configure`.

### Local Validation

You should validate the changes you make to any module locally, prior to pushing your changes in a branch to GitHub.

1. Ensure that you have run `make configure` successfully.

2. Ensure you are signed into the appropriate cloud provider for the module under test in your current console session.

3. Run the Terraform and Golang linters with the following command:

```
make lint
```

4. Once you have satisfied the linters, the following command will build example infrastructure in your configured cloud, run the tests, and then tear down the infrastructure it created:

```
make test
```

The pre-commit validations, as well as the `make lint` and `make test` targets, will all be performed in CI. Running these validations locally prior to opening a PR helps ensure a smooth review and merge process.

### Review & Merge Process

Once your change has been tested locally and your branch pushed up, open a new Pull Request for your branch to the default branch of this repository.

The title of your Pull Request will determine the version bump for this change, and the title must be in [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification) format in order to merge.

Ensure your CI workflows are passing; seek approval from teammates and address any feedback; seek any explicit approvals required by the CODEOWNERS file. You may merge the PR as soon as all requirements are met, and a new release and tag will be automatically created for you.

### Automatic Updates

The shared configuration and workflow files in this repository are largely managed through the [launch-terraform-skeleton](https://github.com/launchbynttdata/launch-terraform-skeleton) repository. Outside of perhaps the `.gitignore` to account for specific files being generated by certain Terraform modules, there should not be much cause to update these files on a per-repo basis, and making changes to them individually is discouraged.

If desired, you can check for and run these updates locally in a branch if you have the `copier` tool installed. Some example commands are included below:

```
# Check for updates, optionally checking prerelease versions
copier check-update [--prereleases]

# Run an update, using default answers if there are any. We use tasks, which requires --trust to be set.
copier update --defaults --trust [--prereleases]

# Recopy from the source, and --overwrite all templated files in the process
copier recopy --defaults --trust --overwrite [--prereleases]
```

Automatic updates will run through a scheduled workflow, and if the post-update tests are successful, the Pull Request created will automatically merge. Conflicts in the update or failures to test may leave a Pull Request outstanding, which needs to be addressed by a Launch Engineer.

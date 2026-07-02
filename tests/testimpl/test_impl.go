package testimpl

import (
	"context"
	"strconv"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/appconfig"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestComposableComplete verifies the deployed AppConfig deployment and exercises a reversible tag write.
func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	client, arn := verifyDeployment(t, ctx)
	exerciseTagWrite(t, client, arn)
}

// TestComposableCompleteReadOnly verifies the deployed AppConfig deployment using read-only AWS API calls.
func TestComposableCompleteReadOnly(t *testing.T, ctx types.TestContext) {
	verifyDeployment(t, ctx)
}

func verifyDeployment(t *testing.T, ctx types.TestContext) (*appconfig.Client, string) {
	opts := ctx.TerratestTerraformOptions()
	region := terraform.Output(t, opts, "region")
	arn := terraform.Output(t, opts, "arn")
	applicationID := terraform.Output(t, opts, "application_id")
	environmentID := terraform.Output(t, opts, "environment_id")
	configurationProfileID := terraform.Output(t, opts, "configuration_profile_id")
	configurationVersion := terraform.Output(t, opts, "configuration_version")
	deploymentNumber := int32Output(t, ctx, "deployment_number")
	state := terraform.Output(t, opts, "state")
	expectedKMSKeyARN := terraform.Output(t, opts, "expected_kms_key_arn")
	expectedKMSKeyIdentifier := terraform.Output(t, opts, "expected_kms_key_identifier")

	require.NotEqual(t, int32(0), deploymentNumber)
	assert.Equal(t, terraform.Output(t, opts, "expected_configuration_version"), configurationVersion)

	client := appConfigClient(t, region)
	deployment, err := client.GetDeployment(context.Background(), &appconfig.GetDeploymentInput{
		ApplicationId:    aws.String(applicationID),
		EnvironmentId:    aws.String(environmentID),
		DeploymentNumber: aws.Int32(deploymentNumber),
	})
	require.NoError(t, err)

	assert.Equal(t, applicationID, aws.ToString(deployment.ApplicationId))
	assert.Equal(t, environmentID, aws.ToString(deployment.EnvironmentId))
	assert.Equal(t, configurationProfileID, aws.ToString(deployment.ConfigurationProfileId))
	assert.Equal(t, configurationVersion, aws.ToString(deployment.ConfigurationVersion))
	assert.Equal(t, deploymentNumber, deployment.DeploymentNumber)
	assert.Equal(t, state, string(deployment.State))
	assert.Equal(t, expectedKMSKeyARN, aws.ToString(deployment.KmsKeyArn))
	assert.Equal(t, expectedKMSKeyIdentifier, aws.ToString(deployment.KmsKeyIdentifier))

	return client, arn
}

func appConfigClient(t *testing.T, region string) *appconfig.Client {
	t.Helper()

	cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
	require.NoError(t, err)

	return appconfig.NewFromConfig(cfg)
}

func exerciseTagWrite(t *testing.T, client *appconfig.Client, resourceARN string) {
	t.Helper()

	const tagKey = "codex-functional-test"
	_, err := client.TagResource(context.Background(), &appconfig.TagResourceInput{
		ResourceArn: aws.String(resourceARN),
		Tags:        map[string]string{tagKey: "true"},
	})
	require.NoError(t, err)

	_, err = client.UntagResource(context.Background(), &appconfig.UntagResourceInput{
		ResourceArn: aws.String(resourceARN),
		TagKeys:     []string{tagKey},
	})
	require.NoError(t, err)
}

func int32Output(t *testing.T, ctx types.TestContext, name string) int32 {
	t.Helper()

	value, err := strconv.ParseInt(terraform.Output(t, ctx.TerratestTerraformOptions(), name), 10, 32)
	require.NoError(t, err)

	return int32(value)
}

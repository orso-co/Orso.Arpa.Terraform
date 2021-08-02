package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestArpaInfrastructure(t *testing.T) {
	terraformInitOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform/azure",
		Vars: map[string]interface{}{
			"backend-config": "key=orso/infra/test/terraform.tfstate",
		},
	})
	terraformApplyOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform/azure",
		Vars: map[string]interface{}{
			"location":    "West Europe",
			"environment": "test",
		},
	})
	defer terraform.Destroy(t, terraformApplyOptions)

	terraform.Init(t, terraformInitOptions)
	terraform.Apply(t, terraformApplyOptions)
}

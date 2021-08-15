package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestArpaInfrastructure(t *testing.T) {
	terraformInitOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform/azure",
		BackendConfig: map[string]interface{}{
			"key": "orso/infra/test/terraform.tfstate",
		},
		PlanFilePath: "terraform.plan",
	})
	terraformApplyOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform/azure",
		Vars: map[string]interface{}{
			"location":    "Germany West Central",
			"environment": "test",
		},
		PlanFilePath: "terraform.plan",
	})
	defer terraform.Destroy(t, terraformApplyOptions)

	terraform.InitAndPlan(t, terraformInitOptions)
	terraform.Apply(t, terraformApplyOptions)
}

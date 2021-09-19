package test

import (
	"encoding/json"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

type DbConfiguration struct {
	Username     string `json:"username"`
	Password     string `json:"password"`
	DatabaseName string `json:"databaseName"`
}

type InputVars struct {
	DbConfig    DbConfiguration `json:"dbconfig"`
	Location    string          `json:"location"`
	Environment string          `json:"environment"`
}

var testInputVariables = InputVars{
	DbConfig: DbConfiguration{
		Username:     "pleasechangeme",
		Password:     "p1easeChangeMe!",
		DatabaseName: "orso-arpa",
	},
	Location:    "Germany West Central",
	Environment: "test",
}

func getTestVariables(vars InputVars) map[string]interface{} {
	in, _ := json.Marshal(vars)
	var out map[string]interface{}
	json.Unmarshal(in, &out)
	return out
}

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
		Vars:         getTestVariables(testInputVariables),
		PlanFilePath: "terraform.plan",
	})
	defer terraform.Destroy(t, terraformApplyOptions)

	terraform.InitAndPlan(t, terraformInitOptions)
	terraform.Apply(t, terraformApplyOptions)
}

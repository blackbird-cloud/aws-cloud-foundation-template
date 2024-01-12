include {
  path = find_in_parent_folders()
}

include "remote_state" {
  path = find_in_parent_folders("remote_state.hcl")
}

dependency "organization" {
  config_path = "../..//00-organization"
  mock_outputs = {
    organization = {
      roots = [
        {
          id = "r-12345"
        }
      ]
    }
  }
}

dependency "account" {
  config_path = "../..//01-account"
  mock_outputs = {
    account_id = "123"
  }
}

terraform {
  source = "tfr:///blackbird-cloud/cloudformation-stackset/aws//?version=1.0.1"
}

inputs = {
  name         = "AWSCloudFormationStackSetExecutionRole"
  template_url = "https://s3.amazonaws.com/cloudformation-stackset-sample-templates-us-east-1/AWSCloudFormationStackSetExecutionRole.yml"
  description  = "Cloudformation account execution role."

  parameters = {
    AdministratorAccountId = dependency.account.outputs.account_id
  }

  auto_deployment = {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]

  operation_preferences = {
    max_concurrent_count    = 10
    failure_tolerance_count = 9
    region_concurrency_type = "PARALLEL"
  }

  permission_model = "SERVICE_MANAGED"
  stackset_instance_organizational_unit_ids = [
    dependency.organization.outputs.organization.roots[0].id
  ]
}

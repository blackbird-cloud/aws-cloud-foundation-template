include {
  path = find_in_parent_folders()
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

terraform {
  source = "tfr:///blackbird-cloud/cloudformation-stackset/aws//?version=1.0.1"
}

inputs = {
  name          = "terraform-state"
  template_body = file("${get_repo_root()}/templates/terraform-state.yaml")
  description   = "S3 bucket and KMS key for storing terraform state."

  auto_deployment = {
    enabled                          = true
    retain_stacks_on_account_removal = true
  }

  operation_preferences = {
    max_concurrent_count    = 10
    failure_tolerance_count = 9
    region_concurrency_type = "PARALLEL"
  }

  permission_model = "SERVICE_MANAGED"

  stackset_instance_organizational_unit_ids = [
    dependency.organization.outputs.organization.roots[0].id,
  ]
}

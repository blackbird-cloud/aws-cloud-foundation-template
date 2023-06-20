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

locals {
  global = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
}

terraform {
  source = "tfr:///blackbird-cloud/cloudformation-stackset/aws//?version=1.0.1"
}

inputs = {
  name          = "admin-assumable-role"
  template_body = file("${get_repo_root()}/templates/iam-role.yaml")
  description   = "Assumable role for AdminAccess"

  auto_deployment = {
    enabled                          = true
    retain_stacks_on_account_removal = true
  }

  capabilities = ["CAPABILITY_NAMED_IAM"]

  parameters = {
    RoleName          = local.global.github_role_name
    PrincipalARN      = local.global.github_role_arn
    ManagedPolicyARNs = "arn:aws:iam::aws:policy/AdministratorAccess"
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

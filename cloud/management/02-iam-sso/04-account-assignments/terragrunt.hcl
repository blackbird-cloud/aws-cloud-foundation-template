include {
  path = find_in_parent_folders()
}

dependency "organization" {
  config_path = "../..//00-organization"
  mock_outputs = {
    organization = {
      accounts = [
        {
          id = "123123123"
        }
      ]
    }
  }
}

dependency "permission_sets" {
  config_path = "..//03-permission-sets"
  mock_outputs = {
    permission_sets = {
      AdministratorAccess = {
        arn  = "arn:123"
        name = "arn"
      }
    }
  }
}

dependency "groups" {
  config_path = "..//02-groups"
  mock_outputs = {
    groups = {
      Administrators = {
        display_name = "display_name"
      }
    }
  }
}

terraform {
  source = "tfr:///blackbird-cloud/ssoadmin/aws//modules/account-assignments?version=1.0.1"
}

inputs = {
  account_assignments = [
    for account in dependency.organization.outputs.organization.accounts : {
      account             = account.id
      principal_type      = "GROUP",
      principal_name      = dependency.groups.outputs.groups.Administrators.display_name
      permission_set_arn  = dependency.permission_sets.outputs.permission_sets.AdministratorAccess.arn
      permission_set_name = dependency.permission_sets.outputs.permission_sets.AdministratorAccess.name
    }
  ]
}

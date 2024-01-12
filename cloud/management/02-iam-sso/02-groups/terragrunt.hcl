include {
  path = find_in_parent_folders()
}

include "remote_state" {
  path = find_in_parent_folders("remote_state.hcl")
}

dependency "users" {
  config_path = "..//01-users"
  ## MANUAL STEP: On initial run align the following value with 01-users, make sure all emails registered 01-users are here. user_id value can be left "user_id"
  mock_outputs = {
    users = {
      "john.doe@email.com" = {
        user_id = "user_id"
      }
    }
  }
}

dependency "organization" {
  config_path  = "../..//00-organization"
  skip_outputs = true
}

terraform {
  source = "tfr:///blackbird-cloud/identitystore/aws//modules/groups?version=1.0.3"
}

inputs = {
  groups = [
    {
      display_name = "Administrators"
      description  = "Administrators"
      members = [
        dependency.users.outputs.users["john.doe@email.com"].user_id,
      ]
    }
  ]
}

include {
  path = find_in_parent_folders()
}

dependency "organization" {
  config_path  = "../..//00-organization"
  skip_outputs = true
}

terraform {
  source = "tfr:///blackbird-cloud/identitystore/aws//modules/users?version=1.0.3"
}

inputs = {
  users = [
    {
      email       = "john.doe@email.com"
      user_name   = "john.doe@email.com"
      given_name  = "John"
      family_name = "Doe"
    }
  ]
}

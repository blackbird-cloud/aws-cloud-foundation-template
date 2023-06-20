include {
  path = find_in_parent_folders()
}

dependency "organization" {
  config_path  = "..//00-organization"
  skip_outputs = true
}

terraform {
  source = "tfr:///blackbird-cloud/account-info/aws//?version=1.0.2"
}

inputs = {
  aws_sso_permission_sets = []
}

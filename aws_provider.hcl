locals {
  global                  = read_terragrunt_config("global.hcl").locals
  organization_name       = local.global.organization_name
  administrator_role_name = local.global.administrator_role_name
  account_name            = split("/", replace(get_original_terragrunt_dir(), get_terragrunt_dir(), ""))[2]
}

generate "provider" {
  path      = "aws-provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.global.region}"
  %{if get_env("CI", "false") == "false"}
  profile = "${local.organization_name}-${local.account_name}-${local.administrator_role_name}"
  %{endif}
}
EOF
}

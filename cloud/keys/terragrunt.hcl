locals {
  global          = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
  github_iam_role = "arn:aws:iam::${local.account_id}:role/${local.global.github_role_name}"
  account_name    = reverse(split("/", get_parent_terragrunt_dir()))[0]
  ### Enter manually
  account_id = "ACCOUNT-ID"
  ###
}

download_dir = "${get_repo_root()}/.terragrunt-cache"

generate "provider" {
  path      = "aws-provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  region = "${local.global.region}"
  %{if get_env("CI", "false") == "false"}
  profile = "${local.global.organization_name}-${local.account_name}-${local.global.administrator_permission_set_name}"
  %{else}
  assume_role {
    role_arn = "${local.github_iam_role}"
  }
  %{endif}
}
EOF
}

inputs = {
  tags = {
    terragrunt = get_path_from_repo_root()
    repository = local.global.repository
  }
}


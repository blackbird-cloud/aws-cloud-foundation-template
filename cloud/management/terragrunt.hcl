locals {
  ## MANUAL STEP: Enter manually
  account_id = "<my account id>"
  bucket     = "<my bucket name>"
  ## ===========================

  ## Statics
  is_mgmt_account = true
  global          = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
  aws_provider    = read_terragrunt_config(find_in_parent_folders("aws_provider.hcl"))
  iam_role        = get_env("CI", "false") == "true" && local.is_mgmt_account == false ? local.github_iam_role : null
  account_name    = reverse(split("/", get_parent_terragrunt_dir()))[0]
  profile         = "${local.global.organization_name}-${local.account_name}-${local.global.administrator_role_name}"
  github_iam_role = "arn:aws:iam::${local.account_id}:role/${local.global.github_role_name}"
}

generate = local.aws_provider.generate

iam_role = local.iam_role

remote_state {
  backend = "s3"
  config = {
    encrypt = true
    bucket  = local.bucket
    key     = "${get_path_from_repo_root()}/terraform.tfstate"
    region  = local.global.region
    profile = get_env("CI", "false") == "false" ? local.profile : null
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = {
  tags = {
    terragrunt = get_path_from_repo_root()
    project    = local.global.project
  }
}



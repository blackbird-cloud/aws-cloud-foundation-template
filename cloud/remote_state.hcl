locals {
  global = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
}

remote_state {
  backend = "s3"
  config = {
    encrypt = true
    bucket  = local.global.remote_state_bucket
    key     = "${get_path_from_repo_root()}/terraform.tfstate"
    region  = local.global.region
    profile = get_env("CI", "false") == "false" ? "${local.global.organization_name}-management-${local.global.administrator_permission_set_name}" : null
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

prevent_destroy = true

include {
  path = find_in_parent_folders()
}

include "remote_state" {
  path = find_in_parent_folders("remote_state.hcl")
}

dependency "account" {
  config_path = "../..//01-account"
}

dependency "key" {
  config_path = "${get_repo_root()}/cloud/keys/10-keys//01-terraform-state"
}

locals {
  global = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
}

terraform {
  source = "tfr:///terraform-aws-modules/s3-bucket/aws//?version=3.14.0"
}

inputs = {
  bucket_prefix = "${local.global.organization_name}-terraform-state"

  restrict_public_buckets = true
  ignore_public_acls      = true
  block_public_policy     = true
  block_public_acls       = true

  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = true
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = dependency.key.outputs.kms.arn
      }
    }
  }
  versioning = {
    enabled = true
  }
}

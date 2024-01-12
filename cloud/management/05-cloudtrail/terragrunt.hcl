include {
  path = find_in_parent_folders()
}

include "remote_state" {
  path = find_in_parent_folders("remote_state.hcl")
}

dependency "account" {
  config_path = "..//01-account"
}

dependency "key" {
  config_path = "${get_repo_root()}/cloud/keys/10-keys//03-cloudtrail"
}

dependency "bucket" {
  config_path = "${get_repo_root()}/cloud/logs/02-logging//01-bucket"
}

terraform {
  source = "tfr:///cloudposse/cloudtrail/aws//?version=0.23.0"
}

inputs = {
  name                          = "cloudtrail-organization"
  s3_bucket_name                = dependency.bucket.outputs.s3_bucket_id
  kms_key_arn                   = dependency.key.outputs.kms.arn
  enable_log_file_validation    = true
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
}

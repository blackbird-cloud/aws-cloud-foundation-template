include {
  path = find_in_parent_folders()
}

include "remote_state" {
  path = find_in_parent_folders("remote_state.hcl")
}

dependency "account" {
  config_path = "../..//01-account"
}

locals {
  policies = read_terragrunt_config(find_in_parent_folders("policies.hcl")).locals
  global   = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
}

terraform {
  source = "tfr:///blackbird-cloud/kms-key/aws//?version=1.0.0"
}

inputs = {
  name = "terraform-state"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "mykey-policy",
    "Statement": [
       ${local.policies.statements.keys_account_root},
        {
          "Sid": "Allow keys account Administrators to manage the KMS key.",
          "Effect": "Allow",
          "Principal": {
              "AWS": [
                "${dependency.account.outputs.sso_roles.AdministratorAccess.arn}",
                "arn:aws:iam::${dependency.account.outputs.account_id}:role/${local.global.github_role_name}"
              ]
          },
          "Action": ${local.policies.actions.key_admin},
          "Resource": "*"
        },
        {
          "Sid": "Allow management account to assign usage of the KMS key.",
          "Effect": "Allow",
          "Principal": {
              "AWS": "arn:aws:iam::${local.global.management_account_id}:root"
          },
          "Action":${local.policies.actions.key_usage},
          "Resource": "*"
        },
        {
          "Sid": "Allow GitHub bootstrap usage of the KMS key.",
          "Effect": "Allow",
          "Principal": {
              "AWS": "${local.global.github_actions_state_role_arn}"
          },
          "Action": ${local.policies.actions.key_usage},
          "Resource": "*"
        }
    ]
}
EOF
}

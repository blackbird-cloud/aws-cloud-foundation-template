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

dependency "bucket" {
  config_path = "..//01-bucket"
}

locals {
  global = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
}


terraform {
  source = "tfr:///blackbird-cloud/s3-bucket-policy/aws//?version=0.1.0"
}

inputs = {
  s3_bucket_id                          = dependency.bucket.outputs.s3_bucket_id
  attach_require_latest_tls_policy      = false
  attach_deny_insecure_transport_policy = false
  policy                                = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "RootAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${dependency.account.outputs.account_id}:root"
      },
      "Action": "s3:*",
      "Resource": [
        "${dependency.bucket.outputs.s3_bucket_arn}",
        "${dependency.bucket.outputs.s3_bucket_arn}/*"
      ]
    },
    {
      "Sid": "Allow access for Administrators",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
            "${dependency.account.outputs.sso_roles.AdministratorAccess.arn}"
        ]
      },
      "NotAction": [
        "s3:GetObject",
        "s3:PutObject*",
        "s3:DeleteObject*",
        "s3:DeleteBucket*"
      ],
      "Resource": [
        "${dependency.bucket.outputs.s3_bucket_arn}",
        "${dependency.bucket.outputs.s3_bucket_arn}/*"
      ]
    },
    {
      "Sid": "Allow bucket list access for ${local.global.github_role_name}",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
            "${local.global.github_actions_state_role_arn}"
        ]
      },
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "${dependency.bucket.outputs.s3_bucket_arn}"
      ]
    },
    {
      "Sid": "Allow bucket object access for ${local.global.github_role_name}",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
            "${local.global.github_actions_state_role_arn}"
        ]
      },
      "Action": [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObject"
      ],
      "Resource": [
        "${dependency.bucket.outputs.s3_bucket_arn}/*"
      ]
    },
    {
      "Sid": "EnforcedTLS",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "${dependency.bucket.outputs.s3_bucket_arn}",
        "${dependency.bucket.outputs.s3_bucket_arn}/*"
      ],
      "Condition": {
          "Bool": {
              "aws:SecureTransport": "false"
          }
      }
    },
    {
      "Sid": "DenyOutdatedTLS",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
          "${dependency.bucket.outputs.s3_bucket_arn}",
          "${dependency.bucket.outputs.s3_bucket_arn}/*"
      ],
      "Condition": {
          "NumericLessThan": {
              "s3:TlsVersion": "1.2"
          }
      }
    }
  ]
}
EOF
}

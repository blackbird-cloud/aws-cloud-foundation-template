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
  s3_bucket_id = dependency.bucket.outputs.s3_bucket_id
  # attach_elb_log_delivery_policy = true
  # attach_lb_log_delivery_policy  = true
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "Allow source account access to the bucket",
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
            "${dependency.account.outputs.sso_roles.AdministratorAccess.arn}",
            "arn:aws:iam::${dependency.account.outputs.account_id}:role/${local.global.github_role_name}"
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
      "Sid": "AWSCloudTrailAclCheck",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "${dependency.bucket.outputs.s3_bucket_arn}"
    },
    {
      "Sid": "AWSCloudTrailWrite",
      "Effect": "Allow",
      "Principal": {
        "Service": "cloudtrail.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${dependency.bucket.outputs.s3_bucket_arn}/AWSLogs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Sid" : "Allow ALB Frankfurt account to deliver logs",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::054676820928:root"
      },
      "Action": "s3:PutObject",
      "Resource": "${dependency.bucket.outputs.s3_bucket_arn}/*"

    },
    {     
      "Sid": "Allow ELB Log delivery", 
      "Effect": "Allow",
      "Principal": {
        "Service": "logdelivery.elasticloadbalancing.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${dependency.bucket.outputs.s3_bucket_arn}/AWSLogs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control",
          "aws:ResourceOrgID": "${dependency.account.outputs.organization.id}"
        }
      }
    },
    {
      "Sid": "AWSLogDeliveryWrite",
      "Effect": "Allow",
      "Principal": {
          "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${dependency.bucket.outputs.s3_bucket_arn}/*",
      "Condition": {
          "StringEquals": {
              "s3:x-amz-acl": "bucket-owner-full-control",
              "aws:ResourceOrgID": "${dependency.account.outputs.organization.id}"
          }
      }
    },
    {
      "Sid": "AWSLogDeliveryAclCheck",
      "Effect": "Allow",
      "Principal": {
          "Service": "delivery.logs.amazonaws.com"
      },
      "Action": [
          "s3:GetBucketAcl",
          "s3:ListBucket"
      ],
      "Resource": [
        "${dependency.bucket.outputs.s3_bucket_arn}",
        "${dependency.bucket.outputs.s3_bucket_arn}/*"
      ],
      "Condition": {
        "StringEquals": {
            "aws:ResourceOrgID": "${dependency.account.outputs.organization.id}"
        }
      }
    },
    {
      "Sid": "S3ServerAccessLogsPolicy",
      "Effect": "Allow",
      "Principal": {
        "Service": "logging.s3.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "${dependency.bucket.outputs.s3_bucket_arn}/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control",
          "aws:ResourceOrgID": "${dependency.account.outputs.organization.id}"
        }
      }
    }
  ]
}
EOF
}

locals {
  statements = {
    keys_account_root = jsonencode(
      {
        "Sid" : "Allow keys account to manage the KMS key.",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::YOUR_KEYS_ACCOUNT_ID:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      }
    )
  }
  actions = {
    key_usage = jsonencode([
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ])
    key_decrypt = jsonencode([
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ])
    key_encrypt = jsonencode([
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ])
    key_admin = jsonencode([
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ])
    key_manage_grants = jsonencode([
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ])
  }
}

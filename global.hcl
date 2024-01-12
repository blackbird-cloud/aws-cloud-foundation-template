locals {
  repository = reverse(split("/", get_repo_root()))[0]

  ### Enter manually
  github_role_name = "GitHubActions"
  # For local usage, configure your credentialls under a profile with the following naming convention:
  # <local.organization_name>-<AWS account name>-${local.administrator_permission_set_name}

  # This defaults to AdministratorAccess, but if you use something else, please update it below.
  administrator_permission_set_name = "AdministratorAccess"

  # The name of your company / organization. Used to for local AWS access, must match with your profile naming convention.
  organization_name = "your-org-name"

  # The teraform state bucket created with Cloudfomation stack initially, and later on the one created by Terraform.
  remote_state_bucket = "your-state-bucket-name"

  # The selected AWS region to create all cloud resources.
  region = "your-aws-region"

  # # The ARN of the role created by the github-oidc-role Cloudformation template.
  github_actions_state_role_arn = "your-oidc-role-arn"

  # The email domain used for creating AWS accounts by the Organization module
  account_email_domain = "your-email-domain"

  management_account_id = "your-management-account-id"

  logs_account_id = "your-logs-account-id"
  ## ===========================
}

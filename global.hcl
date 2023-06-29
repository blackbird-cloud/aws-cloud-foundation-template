locals {
  repository       = split("/", get_repo_root())[0]
  github_role_name = "GitHub"
  # For local usage, configure your credentialls under a profile with the following naming convention:
  # <local.organization_name>-<AWS account name>-${local.administrator_role_name}
  # This defaults to AdministratorAccess, but if you use something else, please update it below.
  administrator_role_name = "AdministratorAccess"
  # The name of your company. Used to for local AWS access, must match with your profile naming convention.
  organization_name = "myorg"

  ### Enter manually
  # The selected AWS region to create all cloud resources.
  region = "eu-central-1"

  # The ARN of the role created by the github-oidc-provider Cloudformation template.
  github_role_arn = ""

  # The email domain used for creating AWS accounts by the Organization module
  account_email_domain = "acme.com"
  ## ===========================
}

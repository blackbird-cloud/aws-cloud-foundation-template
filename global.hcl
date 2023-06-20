locals {
  account_email_label_prefix = local.project
  administrator_role_name    = "AdministratorAccess"
  github_role_name           = "GitHub"

  ### MANUAL STEP: Enter manually
  region               = "eu-central-1"
  organization_name    = "myorg"
  project              = "mycloud"
  github_role_arn      = ""
  account_email_domain = "acme.com"
  ## ===========================
}

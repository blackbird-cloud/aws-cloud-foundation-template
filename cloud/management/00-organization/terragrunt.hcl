include {
  path = find_in_parent_folders()
}

locals {
  global = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
}

terraform {
  source = "tfr:///blackbird-cloud/organization/aws//?version=2.1.0"
}

inputs = {
  aws_service_access_principals = [
    "sso.amazonaws.com",
    "backup.amazonaws.com",
    "securityhub.amazonaws.com",
    "guardduty.amazonaws.com",
    "inspector2.amazonaws.com",
    "aws-artifact-account-sync.amazonaws.com",
    "health.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "ram.amazonaws.com",
    "ssm.amazonaws.com",
    "ipam.amazonaws.com",
    "reachabilityanalyzer.networkinsights.amazonaws.com",
    "reporting.trustedadvisor.amazonaws.com",
    "servicequotas.amazonaws.com",
    "account.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "malware-protection.guardduty.amazonaws.com"
  ]
  enabled_policy_types = [] # ["BACKUP_POLICY", "SERVICE_CONTROL_POLICY", "TAG_POLICY"]
  feature_set          = "ALL"
  organizational_units = [
    {
      name     = "environments"
      accounts = []
      tags     = {}
      organizational_units = [
        {
          name                 = "develop"
          organizational_units = []
          accounts             = []
          tags                 = {}
        },
        {
          name                 = "production"
          organizational_units = []
          accounts             = []
          tags                 = {}
        }
      ],
    },
    {
      name                 = "tooling"
      organizational_units = []
      tags                 = {}
      accounts             = []
    },
    {
      name                 = "security"
      organizational_units = []
      tags                 = {}
      accounts = [
        {
          name  = "security-tooling"
          email = "info+${local.global.account_email_label_prefix}-security-tooling@${local.global.account_email_domain}"
          delegated_administrator_services = [
            "config.amazonaws.com",
            "guardduty.amazonaws.com",
            "inspector2.amazonaws.com",
            "securityhub.amazonaws.com",
            "config-multiaccountsetup.amazonaws.com"
          ]
        }
      ]
    }
  ]

  organizations_policies = {}
  # https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html

  securityhub_auto_enable = true

  primary_contact = {
    address_line_1  = "Somewhere"
    address_line_2  = "42"
    city            = "Amsterdam"
    company_name    = "ACME inc."
    country_code    = "NL"
    postal_code     = "1001AA"
    state_or_region = "Noord-Holland"
    phone_number    = "+155502523"
    website_url     = "https://www.acme.inc"
    full_name       = "John Doe"
  }

  billing_contact = {
    name          = "John Doe"
    title         = "CTO"
    email_address = "john.doe@acme.inc"
    phone_number  = "+155502523"
  }

  security_contact = {
    name          = "John Doe"
    title         = "CTO"
    email_address = "john.doe@acme.inc"
    phone_number  = "+155502523"
  }

  operations_contact = {
    name          = "John Doe"
    title         = "CTO"
    email_address = "john.doe@acme.inc"
    phone_number  = "+155502523"
  }
}

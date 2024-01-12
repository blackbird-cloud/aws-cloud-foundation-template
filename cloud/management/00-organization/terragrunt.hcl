prevent_destroy = true

include {
  path = find_in_parent_folders()
}

include "remote_state" {
  path = find_in_parent_folders("remote_state.hcl")
}


locals {
  global = read_terragrunt_config(find_in_parent_folders("global.hcl")).locals
  ### Enter manually
  email_user = "YOUR-EMAIL-USER" # E.g. info, which will be prefixed to "@${local.global.account_email_domain}"
  ###
}

terraform {
  source = "tfr:///blackbird-cloud/organization/aws//?version=2.1.4"
}

inputs = {
  aws_service_access_principals = [
    "access-analyzer.amazonaws.com",
    "account.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com",
    "sso.amazonaws.com",
    # "backup.amazonaws.com",
    # "securityhub.amazonaws.com",
    # "guardduty.amazonaws.com",
    # "inspector2.amazonaws.com",
    # "aws-artifact-account-sync.amazonaws.com",
    # "health.amazonaws.com",
    # "config.amazonaws.com",
    # "ram.amazonaws.com",
    # "ssm.amazonaws.com",
    # "ipam.amazonaws.com",
    # "reachabilityanalyzer.networkinsights.amazonaws.com",
    # "networkmanager.amazonaws.com",
    # "reporting.trustedadvisor.amazonaws.com",
    # "servicequotas.amazonaws.com",
    # "config-multiaccountsetup.amazonaws.com",
    # "malware-protection.guardduty.amazonaws.com",
    # "fms.amazonaws.com"
  ]
  enabled_policy_types = ["BACKUP_POLICY", "SERVICE_CONTROL_POLICY", "TAG_POLICY"]

  feature_set = "ALL"
  organizational_units = [
    {
      name = "environments"
      accounts = [
        # {
        #   name                             = "develop"
        #   email                            = "${local.email_user}+${local.global.organization_name}-develop@${local.global.account_email_domain}"
        #   delegated_administrator_services = []
        # },
      ]
      tags                 = {}
      organizational_units = [],
    },
    {
      name                 = "shared"
      organizational_units = []
      tags                 = {}
      accounts = [
        # {
        #   name                             = "tools"
        #   email                            = "${local.email_user}+${local.global.organization_name}-tools@${local.global.account_email_domain}"
        #   delegated_administrator_services = []
        # },
      ]
    },
    {
      name                 = "security-and-compliance"
      organizational_units = []
      tags                 = {}
      accounts = [
        # {
        #   name  = "security"
        #   email = "${local.email_user}+${local.global.organization_name}-security@${local.global.account_email_domain}"
        #   delegated_administrator_services = [
        #     "config.amazonaws.com",
        #     "guardduty.amazonaws.com",
        #     "inspector2.amazonaws.com",
        #     "securityhub.amazonaws.com",
        #     "config-multiaccountsetup.amazonaws.com"
        #   ]
        # },
        {
          name                             = "keys"
          email                            = "${local.email_user}+${local.global.organization_name}-keys@${local.global.account_email_domain}"
          delegated_administrator_services = []
        },
        {
          name                             = "logs"
          email                            = "${local.email_user}+${local.global.organization_name}-logs@${local.global.account_email_domain}"
          delegated_administrator_services = []
        },
        # {
        #   name  = "backups"
        #   email = "${local.email_user}+${local.global.organization_name}-backups@${local.global.account_email_domain}"
        #   delegated_administrator_services = [
        #     "backup.amazonaws.com"
        #   ]
        # }
      ]
    }
  ]

  organizations_policies = {
    # DenyMemberAccountInstances = {
    #   content = jsonencode({
    #     "Version" : "2012-10-17",
    #     "Statement" : [
    #       {
    #         "Sid" : "DenyMemberAccountInstances",
    #         "Effect" : "Deny",
    #         "Action" : [
    #           "sso:CreateInstance"
    #         ],
    #         "Resource" : "*"
    #       }
    #     ]
    #   })
    #   ous          = ["root"]
    #   description  = "Deny other accounts to create SSO instances."
    #   skip_destroy = false
    #   type         = "SERVICE_CONTROL_POLICY"
    # }
  }
  # https://docs.aws.amazon.com/organizations/latest/userguide/orgs_integrate_services_list.html

  primary_contact = {
    address_line_1  = "My Street"
    address_line_2  = "My house number / office number"
    city            = "My City"
    company_name    = "My Company"
    country_code    = "My Country Code"
    postal_code     = "My Postal Code"
    state_or_region = "My State or Region"
    phone_number    = "My Phone Number"
    website_url     = "My Website URL"
    full_name       = "My Full Name"
  }

  billing_contact = {
    name          = "My Full Name"
    title         = "My Job Title"
    email_address = "My Email Address"
    phone_number  = "My Phone Number"
  }

  security_contact = {
    name          = "My Full Name"
    title         = "My Job Title"
    email_address = "My Email Address"
    phone_number  = "My Phone Number"
  }

  operations_contact = {
    name          = "My Full Name"
    title         = "My Job Title"
    email_address = "My Email Address"
    phone_number  = "My Phone Number"
  }
}

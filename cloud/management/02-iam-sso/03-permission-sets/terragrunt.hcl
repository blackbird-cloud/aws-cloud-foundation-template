include {
  path = find_in_parent_folders()
}

dependency "organization" {
  config_path  = "../..//00-organization"
  skip_outputs = true
}

terraform {
  source = "tfr:///blackbird-cloud/ssoadmin/aws//modules/permission-sets?version=1.0.1"
}

inputs = {
  permission_sets = [
    {
      name                                = "AdministratorAccess",
      description                         = "AdministratorAccess",
      relay_state                         = "",
      session_duration                    = "PT8H",
      tags                                = {},
      inline_policy                       = "",
      customer_managed_policy_attachments = [],
      policy_attachments                  = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    },
    { name                                = "PowerUserAccess",
      description                         = "PowerUserAccess",
      relay_state                         = "",
      session_duration                    = "PT8H",
      tags                                = {},
      inline_policy                       = "",
      customer_managed_policy_attachments = [],
      policy_attachments                  = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    },
    { name                                = "ViewOnlyAccess",
      description                         = "ViewOnlyAccess",
      relay_state                         = "",
      session_duration                    = "PT8H",
      tags                                = {},
      inline_policy                       = "",
      customer_managed_policy_attachments = [],
      policy_attachments = [
        "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess",
        "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
      ]
    },
    {
      name                                = "Billing",
      description                         = "Billing",
      relay_state                         = "",
      session_duration                    = "PT8H",
      tags                                = {},
      inline_policy                       = ""
      customer_managed_policy_attachments = []
      policy_attachments = [
        "arn:aws:iam::aws:policy/job-function/Billing"
      ]
    }
  ]
}

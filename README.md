# Blackbird Cloud AWS Cloud Environment Template


[![blackbird-logo](https://raw.githubusercontent.com/blackbird-cloud/terraform-module-template/main/.config/logo_simple.png)](https://www.blackbird.cloud)

## Intro

We (Blackbird Cloud) have deployed many AWS cloud environment for our clients. We use this repository as a boilerplate for our cloud deployment.

This Repository includes:
* AWS Cloudformation Stack templates to bootstrap your account after creation.
* Terragrunt and Terraform resources to configure the following services:
    * AWS Organizations
    * AWS IAM Identity Center
    * AWS Cloudformation StackSets
    * AWS KMS key for Terraform state encryption.
    * AWS S3 bucket for Terraform state storage.
    * AWS KMS key for audit log encryption.
    * AWS S3 bucket for audit log collection.
    * AWS Cloudtrial organization configuration.
* GitOps (GitHub Action) pipeline

## How to deploy

1. Create an AWS Account [here](https://portal.aws.amazon.com/billing/signup#/start/email]), name it management. Select the region you would like to deploy your resources to, write down the region and account id.
2. Navigate to Security Credentials, and register a MFA device for your root account.
3. Navigate to your Account page in the Billing console, and enable acces for IAM users.
4. Select the region in which you would like to create your AWS resources.
5. Navigate to AWS Cloudformation => Stacks, and manually deploy the following stack templates in the specified order: `stacks/github-oidc-provider.yaml`, `stacks/github-oidc-role.yaml`, `stacks/terraform-state.yaml`, and `stacks/iam-role.yaml`.
    * For the Github oidc role stack, fill in `GitHubIdentityProviderArn` with the ARN of the IDP created on the `github-oidc-provider` stack. Fill in `SubjectClaimFilters` with the following data relating to your infra repo `repo:YOUR_GITHUB_ORGANIZATION/YOUR_GITHUB_REPOSITORY_NAME:ref:refs/heads/BRANCH_NAME` we advise to deploy use `main` as branch name. This is nessecary to make sure that only GitHub Actions that run on the main branch are allowed to plan and apply changes on AWS. Make sure to protect your main branch, as it will receive AdministratorAccess on your AWS cloud. Once the stack has been created, navigate to its resources, and note down the arn of created IAM role. For `GitHubActionsJumpRoleName` use the same name as you will on the `iam-role` stack `RoleName` parameter.
    * For the `terraform-state` stack, fill in `GithubActionsRoleArn` with the role ARN created in the `github-oidc-role` stack. Once the terraform state stack has been created, note down the bucket name, it will be used as the state bucket for the next steps.
    * For the `iam-role` stack, fill in `PrincipalARN` with the role ARN created in the `github-oidc-role` stack. Make sure to write down the Role name, and configure it in `globals.hcl` at `github_role_name`. Under `ManagedPolicyARNs` one can configure `arn:aws:iam::aws:policy/AdministratorAccess`.
6. Create 2 variables on GitHub -> Settings -> Secrets and variables -> Actions -> Variables
    * `AWS_IAM_ROLE`: fill in `IAM Role ARN` created by github-oidc-role stack
    * `AWS_REGION`: fill in your selected AWS region.
7. On `.github/workflows/aws_deployment.yml` update all occurences of `<my-project-name>` to your github repository name, line 46.
8. On `global.hcl` enter all the required information at the `Enter manually` block.
9. On `cloud/management/terragrunt.hcl` enter all the information under `Enter manually` block. Remember to do the same for the other account their terragrunt files.
10. Go to `cloud/management/00-organization/terragrunt.hcl` and fill in the local values under `Enter manually`, and under inputs fill in the primary, operational, securit, and billing contact information. Configure the accounts you would like to create.
11. (Optional) If your IDP supports provisioning users and groups, you can skip this step, and delete the `cloud/management/02-iam-sso/01-users` folder, and the `cloud/management/02-iam-sso/02-groups` folder.
    * Create the users list on `cloud/management/02-iam-sso/01-users/terragrunt.hcl`, you can remove `john.doe@email.com`.
    *    `cloud/management/02-iam-sso/02-groups/terragrunt.hcl` enter the groups with the users you would like to create. Make sure to assign the users created by adding multiple `dependency.users.outputs.users["USER_EMAIL"].user_id` and replace `USER_EMAIL` with the actual email.
    * On initial run align the `mock_output` value of `dependency "users"` with `01-users`, make sure all emails registered `01-users` are `listed`. `user_id` value can be left `"user_id"`

12. (Optional) On `cloud/management/02-iam-sso/03-permission-sets/terragrunt.hcl` enter the permission-sets you would like to create. We have included some commonly used permission-sets.
13. (Optional) On `cloud/management/02-iam-sso/04-account-assignment/terragrunt.hcl` assign accounts and permission-sets, to users and groups. The default value will deploy the `AdministratorAccess` permission set for the Administrators group.
14. Commit and push, it will trigger the pipeline to run.
    * It will succesfuly create your AWS organization, and *fail* to create all other modules after that.
15. Then there are a few steps to be taken before re-runing the pipeline
    * Open your AWS web console and navigate to Cloudformation => StackSets, then enable trusted access.
    * Open your AWS web console and navigate to IAM Identity Center, then click on enable.
    * You can now choose to use the AWS IAM Center Identity Directory, or configure your own Directory. Read the documentation [here](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source.html) to proceed depending your Organization's IDP.
    * If you choose to use the AWS IAM Identity Center Directory:
        * Configure the MFA settings.
        * On settings => Authentication, enable `Send email OTP for users created from API`.
16. Re-run the failed pipeline and all IAM and StackSets should now deploy succesfully.
17. On `cloud/logs/terragrunt.hcl` enter all the information under `Enter manually` block. Remember to do the same for the other account their terragrunt files.
18. On `cloud/keys/terragrunt.hcl` enter all the information under `Enter manually` block. Remember to do the same for the other account their terragrunt files.
19. On `policies.hcl` replace `YOUR_KEYS_ACCOUNT_ID` with the keys account ID.
20. On `global.hcl` enter `management_account_id` and `logs_account_id`.
21. The pipeline jobs will fail because of missing dependencies, so you will have to retry them a few times until everything has been created.
22. Configure AWS profiles with AdminstratorAccess permissions on your local machine for all created AWS accounts.
23. Update `global.hcl` `remote_state_bucket` to the bucket created at `cloud/management/04-terraform-state/01-bucket`
24. You can now migrate the Terraform state to the newly created Terraform state bucket, and delete the `terraform-state` Cloudformation stack when finished. If you open a termimal in the `cloud` directory, you can execute `terragrunt --terragrunt-non-interactive run-all init -migrate-state -input=true`, you will manually have to enter "yes" a number of times.

## Troubleshooting

### Rate Limited
```
Error: enabling Security Hub Organization Admin Account (XXXXXXXXX): LimitExceededException: AWS Organizations can't complete your request because another request is already in progress. Try again later.
```
If you see this error, it means you are being rate limited by AWS. Simply re-run the failed pipeline and give it another shot.

## Future improvements

[ ] Make Cloudformation bucket public with templates

[ ] Double check CI files and remove hardcodes

[ ] Add mock outputs to organization dependencies

## About Blackbird Cloud

We are [Blackbird Cloud](https://www.blackbird.cloud), Amsterdam based cloud consultancy, and cloud management service provider. We help companies build secure, cost efficient, and scale-able solutions.

Checkout our other :point_right: [terraform modules](https://registry.terraform.io/namespaces/blackbird-cloud)

## Copyright

Copyright © 2017-2023 [Blackbird Cloud](https://www.blackbird.cloud)
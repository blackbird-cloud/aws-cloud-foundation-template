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
    * AWS S3 bucket for Terraform state storage.
    * AWS KMS key for Terraform state encryption.
* GitOps (GitHub Action) pipeline

## How to deploy

1. Create an AWS Account [here](https://portal.aws.amazon.com/billing/signup#/start/email]), name it management. Select the region you would like to deploy your resources to, write down the region and account id.
2. Navigate to AWS Cloudformation => Stacks, and manually deploy both `stacks/github-oidc-provider.yaml` and `stacks/terraform-state.yaml`.
    * For the GitHub oidc provider stack, fill in `SubjectClaimFilters` with the following data relating to your infra repo `repo:YOUR_GITHUB_ORGANIZATION/YOUR_GITHUB_REPOSITORY_NAME:ref:refs/heads/BRANCH_NAME` we advise to deploy use `main` as branch name. This is nessecary to make sure that only GitHub Actions that run on the main branch are allowed to plan and apply changes on AWS. Make sure to protect your main branch, as it will receive AdministratorAccess on your AWS cloud. Once the stack has been created, navigate to its resources, and note down the arn of created IAM role.
    * Once the terraform state stack has been created, note down the bucket name, it will be used as the state bucket for the next steps.
3. Create 2 variables on GitHub -> Settings -> Secrets and variables -> Actions -> Variables
    * `AWS_IAM_ROLE`: fill in `IAM Role ARN` created by github-oidc-provider stack
    * `AWS_REGION`: fill in your selected AWS region.
4. On `.github/workflows/aws_deployment.yml` update all occurences of `<my-project-name>` to your github repository name, line 37.

5. On `cloud/global.hcl` enter all the required information at the `Enter manually` block.
6. On` cloud/management/terragrunt.hcl` enter all the information under `Enter manually` block. Use the bucket name created by `stacks/terraform-state.yaml` for `bucket_name`, and enter the account id from the AWS account you created in step 1.
7. Go to `cloud/00-organization/terragrunt.hcl` and fill in the primary, operational, securit, and billing contact information.

8. (Optional) If your IDP supports provisioning users and groups, you can skip this step, and delete the `cloud/management/02-iam-sso/01-users` folder, and the `cloud/management/02-iam-sso/02-groups` folder.
    * Create the users list on `cloud/management/02-iam-sso/01-users/terragrunt.hcl`, you can remove `john.doe@email.com`.
    *    `cloud/management/02-iam-sso/02-groups/terragrunt.hcl` enter the groups with the users you would like to create. Make sure to assign the users created by adding multiple `dependency.users.outputs.users["USER_EMAIL"].user_id` and replace `USER_EMAIL` with the actual email.
    * On initial run align the `mock_output` value of `dependency "users"` with `01-users`, make sure all emails registered `01-users` are `listed`. `user_id` value can be left `"user_id"`

10. (Optional) On `cloud/management/02-iam-sso/03-permission-sets/terragrunt.hcl` enter the permission-sets you would like to create. We have included some commonly used permission-sets.
11. (Optional) On `cloud/management/02-iam-sso/04-account-assignment/terragrunt.hcl` assign accounts and permission-sets, to users and groups. The default value will deploy the `AdministratorAccess` permission set for the Administrators group.
12. Commit and push, it will trigger the pipeline to run.
    * It will *fail* initially
13. Then there are a few steps to be taken before re-runing the pipeline
    * Open your AWS web console and navigate to Cloudformation => StackSets, then enable trusted access.
    * Open your AWS web console and navigate to IAM Identity Center, then click on enable.
    * Open your AWS web console and navigate to IAM Identity Center => Settings. At the identity source tab, click Actions and select change identity source. Read the documentation [here](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source.html) to proceed depending your Organization's IDP.
14. Re-run the pipeline and all IAM and StackSets should now deploy succesfully. 

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
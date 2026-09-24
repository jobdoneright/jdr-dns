# jdr-dns

Terraform for the Route 53 hosted zones and Google Workspace MX/CNAME records of
the jobdoneright domains, in AWS account `293109759455`.

Changes are delivered by [Spacelift](https://simonmcc.app.spacelift.io/spaces/jobdoneright-01M39J5RV4210RWJBD0AEJRZ57),
stack `jdr-dns` in the `jobdoneright` space. **Merging to `master` applies to
production.** Do not apply from a laptop. The `Makefile` and `scripts/` predate
Spacelift; ignore them.

## Layout

| File                                           | Contents                                                                                                                                                    |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [terraform.tf](terraform.tf)                   | Provider, and one [`jobdoneright/google-workspace-dns/aws`](https://registry.terraform.io/modules/jobdoneright/google-workspace-dns/aws) module per domain. |
| [backend_config.tf](backend_config.tf)         | S3 state: `terraform-tfstate-293109759455/jobdoneright-jdr-dns`, lock table `terraform_locks`, `eu-west-1`.                                                 |
| [versions.tf](versions.tf)                     | Terraform `~> 1.5.0`, AWS provider `~> 6.0`.                                                                                                                |
| [.terraform.lock.hcl](.terraform.lock.hcl)     | Provider lock, committed so review and apply resolve the same provider. Hashes for `linux_amd64`, `darwin_arm64`, `darwin_amd64`.                           |
| [.terraform-version](.terraform-version)       | `1.5.7`, for tfenv.                                                                                                                                         |
| [.spacelift/config.yml](.spacelift/config.yml) | Pins `terraform_version`. Overrides the stack setting.                                                                                                      |
| [.spacelift/iam/](.spacelift/iam/)             | Trust and inline policy for the `jdr-dns` role Spacelift assumes.                                                                                           |

## How a change flows

- **PR opened**: proposed run. `init` and `plan`, reported as the GitHub check
  `spacelift/jdr-dns`. Never applies.
- **Merge to `master`**: tracked run. Plans and, with autodeploy on, applies.

Local work is validation only:

```bash
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

## Stack settings

Configured in Spacelift, not visible from a checkout. Mirrors
[`simonmcc/personal-dns`](https://github.com/simonmcc/personal-dns).

| Setting                 | Value                                                               |
| ----------------------- | ------------------------------------------------------------------- |
| Stack                   | `jdr-dns`, space `jobdoneright-01M39J5RV4210RWJBD0AEJRZ57`          |
| VCS                     | GitHub App `spacelift-io` → `jobdoneright/jdr-dns`, branch `master` |
| Project root            | _(repo root)_                                                       |
| Workflow tool           | Terraform (FOSS), `1.5.7`                                           |
| Spacelift-managed state | `false` — S3 backend                                                |
| Autodeploy              | `true`                                                              |
| AWS integration         | `jdr-dns` → `arn:aws:iam::293109759455:role/jdr-dns`, read + write  |

## Migration from Terraform Cloud

State was in Terraform Cloud, organisation `jdr1`, workspace `jdr-dns`, until
this migration. Do the steps in order. **Do not let the Spacelift stack run
before step 3.** Against an empty state it plans to create every hosted zone,
and new zones get new name servers.

AWS commands below need credentials for account `293109759455`.

### 1. Check the state bucket and lock table still exist

```bash
aws s3api head-bucket --bucket terraform-tfstate-293109759455
aws s3api get-bucket-versioning --bucket terraform-tfstate-293109759455
aws dynamodb describe-table --region eu-west-1 --table-name terraform_locks --query Table.TableStatus
aws s3 ls s3://terraform-tfstate-293109759455/jobdoneright-jdr-dns
```

The last command may find the pre-2023 state object. It has the same lineage
and a lower serial, so step 3 replaces it.

### 2. Stop Terraform Cloud applying

In Terraform Cloud, lock the `jdr1/jdr-dns` workspace and disconnect its VCS
connection. Otherwise merging this change triggers a Terraform Cloud run too.

### 3. Copy state to S3

```bash
# From a master checkout, before this change merges (cloud backend):
terraform login
terraform init
terraform state pull > /tmp/jdr-dns.tfstate
jq '{serial, lineage, terraform_version, resources: (.resources | length)}' /tmp/jdr-dns.tfstate

# From this branch (S3 backend):
terraform init
terraform state push /tmp/jdr-dns.tfstate
terraform state list
```

### 4. Create the IAM role

```bash
aws iam create-role --role-name jdr-dns \
  --assume-role-policy-document file://.spacelift/iam/trust-policy.json
aws iam put-role-policy --role-name jdr-dns --policy-name jdr-dns-terraform \
  --policy-document file://.spacelift/iam/role-policy.json
```

`324880187172` is Spacelift's AWS account. The external ID condition limits the
role to the `jdr-dns` stack in the `simonmcc` Spacelift account.

### 5. Install the Spacelift GitHub App on `jobdoneright`

The `spacelift-io` app is not installed on the `jobdoneright` organisation.
Install it (GitHub → Settings → Applications, or from Spacelift → Source code)
and grant it `jobdoneright/jdr-dns`.

### 6. Create the AWS integration and the stack

```bash
SPACE=jobdoneright-01M39J5RV4210RWJBD0AEJRZ57

spacectl api --variables "{\"space\":\"$SPACE\"}" 'mutation($space:ID!){
  awsIntegrationCreate(name:"jdr-dns", roleArn:"arn:aws:iam::293109759455:role/jdr-dns",
    space:$space, labels:[], durationSeconds:3600,
    generateCredentialsInWorker:false, externalID:"", region:"eu-west-1") { id } }'
```

Create the stack in the UI with the settings above and attach the `jdr-dns`
integration (read and write). Do not trigger a run on `master`: until this
change merges, `master` still has the `cloud` backend.

### 7. Check the plan on this PR

Push a commit to this PR, or re-open it, so Spacelift runs a proposed plan.
Expect `moved` entries and no adds, changes or destroys. The module rename and
the `count` → `for_each` move are covered by `moved` blocks in the module.
Anything else, stop and investigate before merging.

### 8. Merge, then remove the Terraform Cloud workspace

Merging applies the moves. After that tracked run is clean, delete the
`jdr1/jdr-dns` workspace. Then protect `master` with `spacelift/jdr-dns` as a
required check, as `simonmcc/personal-dns` does.

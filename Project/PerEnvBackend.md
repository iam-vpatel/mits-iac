## Per‐Env Backend Config Files

### Why we need per env backend config files ?

We need exactly pattern we want as per env backend config files.
Terraform’s S3 backend block can’t interpolate variables at runtime.
We need to distinguish environments by giving each its own backend‐config file (or CLI flags) with the right bucket and lock table names.

1. Per‐Env Backend Config Files

Create these files under backends/aws-aim/:

```bash
backends/
└── aws-aim/
    ├── dit
    ├── fit
    ├── iat
    ├── ipe
    ├── prod
    └── uat
```

Populate each one like so:

backends/aws-aim/dit

```bash
bucket = "aim-dit-terraform-state-bucket"
dynamodb_table = "aim-dit-terraform-state-lock"
region = "us-east-1"

```

backends/aws-aim/fit

```bash
bucket = "aim-fit-terraform-state-bucket"
dynamodb_table = "aim-fit-terraform-state-lock"
region = "us-east-1"

```

…and so on for iat, ipe, prod, uat.

2. How to Init & Apply

From your module folder (e.g. terraform/aws/modules/nonfed/sm/dev), run:

```bash
# for DIT
terraform init \
  -backend-config=../../../../../backends/aws-aim/dit

terraform validate
terraform plan \
  -var-file=dit.tfvars     \
  -out=plan-dit.tfplan

terraform apply "plan-dit.tfplan"

```

Or equivalently, pass overrides on the CLI:

```bash
terraform init \
  -backend-config="bucket=aim-dit-terraform-state-bucket" \
  -backend-config="dynamodb_table=aim-fit-terraform-state-lock" \
  -backend-config="region=us-east-1"

```

3. Why This Works

- Separate buckets per env prevent state collisions.

- Separate lock tables per env avoid “lost lock” issues when multiple envs share an account.

- We keep the same Terraform code (modules, .tf files) and just point to a different backend each time.

### Summary

- Yes, use per-env bucket and lock names.

- Keep one set of .tf files; just swap the backend-config.

- This cleanly isolates our DIT, FIT, IAT, PROD, UAT states while all or some of envs in the same AWS account.

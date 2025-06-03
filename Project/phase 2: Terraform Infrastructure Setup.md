## Phase 2: Terraform Infrastructure Setup

### Tasks:

- Flesh out and test the `sminstall` module,
- Spin up EC2s with proper tagging, volumes, and networking.

### Deliverables:

- VPC/subnet/SG data-sources or wrapper modules,
- completed EC2 reusable module,
- Automated drift detection PoC. - To reliably store and lock your Terraform state—and catch any
  out-of-band changes (“drift”)—you’ll combine:

  1.  An S3 backend for durable, shared state files
  2.  A DynamoDB table for state‐locking
  3.  Automated Drift Detection via terraform plan -detailed-exitcode

  - Drift happens when someone manually tweaks resources in AWS. To detect it:Run a no-change plan against the current remote state:

```bash
terraform plan \
  -backend-config=../../../backends/aws-aim/dit \
  -var-file=dit.tfvars \
  -detailed-exitcode \
  -out=drift.tfplan

```

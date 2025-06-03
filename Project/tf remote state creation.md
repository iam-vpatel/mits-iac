### Terraform’s S3/DynamoDB backend block can’t provision its own bucket or lock table at init time—you must create those resources before you run terraform init. You have two options:

Terraform’s S3/DynamoDB backend block can’t provision its own bucket or lock table at init time—you must create those resources before you run terraform init. You have two options:

Option A: Manual Creation
Create the S3 bucket in the AWS Console (or via AWS CLI):

aws s3api create-bucket \
 --bucket mits-dev-terraform-state-bucket \
 --region us-east-1 \
 --create-bucket-configuration LocationConstraint=us-east-1

# Enable versioning (optional but recommended)

aws s3api put-bucket-versioning \
 --bucket my-terraform-state-bucket \
 --versioning-configuration Status=Enabled
Create the DynamoDB table for state locks:

aws dynamodb create-table \
 --table-name my-terraform-state-lock \
 --attribute-definitions AttributeName=LockID,AttributeType=S \
 --key-schema AttributeName=LockID,KeyType=HASH \
 --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
 --region us-east-1
Verify both exist, then run your usual

terraform init -backend-config=backends/aws-aim/dit
Option B: “Bootstrap” Terraform Configuration
You can automate bucket/table creation with a separate Terraform config that has no backend block. For example, create a folder terraform/backend-bootstrap/ with:

# terraform/backend-bootstrap/main.tf

provider "aws" {
region = var.aws_region
}

resource "aws_s3_bucket" "tfstate" {
bucket = var.bucket_name
versioning {
enabled = true
}
tags = {
Name = var.bucket_name
}
}

resource "aws_dynamodb_table" "lock" {
name = var.lock_table_name
billing_mode = "PAY_PER_REQUEST"
hash_key = "LockID"

attribute {
name = "LockID"
type = "S"
}

tags = {
Name = var.lock_table_name
}
}

# terraform/backend-bootstrap/variables.tf

variable "aws_region" {
type = string
default = "us-east-1"
}

variable "bucket_name" {
type = string
}

variable "lock_table_name" {
type = string
}

# terraform/backend-bootstrap/terraform.tfvars

bucket_name = "my-terraform-state-bucket"
lock_table_name = "my-terraform-state-lock"
aws_region = "us-east-1"
Then:

cd terraform/backend-bootstrap
terraform init
terraform apply -auto-approve
Once that completes, your bucket & lock table exist. Now you can go back to your env folders and run:

cd ../modules/nonfed/sminstall/dit
terraform init -backend-config=../../../backends/aws-aim/dit
terraform apply -var-file=dit.tfvars
Why This Separation?
Backend config can’t self-provision: Terraform must already be able to write state to that backend.

Isolation: You keep your “state-management infra” separate from your “application infra.”

Repeatable: Anyone can bootstrap a fresh AWS account by running the backend-bootstrap first, then all the modules.

Choose manual for a quick one-off, or bootstrap Tf config for full automation.

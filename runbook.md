Here’s a comprehensive **Runbook** for a Mac-based engineer to go from zero → Non Fed RHEL 9 \*\* ec2vms servers in AWS, using `sminstall` Terraform module and (optionally) a Jenkins pipeline to orchestrate Terraform → Ansible.

---

```
terraform init -backend-config=/Users/vikaspatel/Projects/github_projects/mits-iac/backends/aws-mits/dev

```

# Runbook: Spinning up ec2vms EC2s on Mac

## Prerequisites

1. **MacOS** (Catalina or later)
2. **Homebrew** installed
3. **AWS CLI** configured with Power-User credentials
4. **Terraform** v1.x installed
5. **Git** installed
6. **(Optional) Jenkins** accessible & Jenkinsfile in your repo

---

## 1. Install Local Tools

```bash
# Homebrew if not already:
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# AWS CLI
brew install awscli

# Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Git & (if testing playbook locally) Ansible:
brew install git ansible
```

Verify:

```bash
aws --version
terraform version
ansible --version
```

---

## 2. Clone the Repo

```bash
cd ~/Projects
git clone git@bitbucket.org:your_org/aim-infra-terransible.git
cd aim-infra-terransible/terraform/aws/modules/nonfed/sminstall
```

---

## 3. Configure Environment Variables

Set your environment specifics. In your shell (or add to `~/.zshrc`):

```bash
export TF_VAR_function="sminstall"
export TF_VAR_product_name="Nonfed-SM"
export TF_VAR_environment="dit"          # change per env
export TF_VAR_aws_region="us-east-1"
export TF_VAR_account_no="123456789012"
export TF_VAR_subnet_id="subnet-0123456789abcdef0"
export TF_VAR_security_group_id="sg-0abc1234def567890"
export TF_VAR_key_name="my-ec2-key"
export TF_VAR_iam_instance_profile="ec2-ec2vms-role"

# (Optional) For KMS
# export TF_VAR_kms_key_id="arn:aws:kms:us-east-1:...:key/..."

# (Clean-install mode) skip Ansible/webex:
# leave TF_VAR_ansible_repo etc. unset
```

### 1 Rely entirely on \*.tfvars

We don’t strictly need the “export TF*VAR*…” step if you’re already carrying all of your per-environment settings in a \*.tfvars file under each env folder. In practice there are two common patterns:

```
cd terraform/aws/modules/nonfed/sminstall/dit
terraform init \
  -backend-config=../../../backends/aws-aim/dit

# Pulls everything from dit.tfvars—no exports needed
terraform plan  -var-file=dit.tfvars
terraform apply -var-file=dit.tfvars -auto-approve

```

All your values (function, environment, subnet_id, etc.) live in dit/dit.tfvars, so you never have to export them.

### 2 Environment variables + minimal tfvars

If we prefer not to check secrets (or common settings) into VCS at all, we can keep only the bare essentials in your \*.tfvars (e.g. network IDs) and push everything else via TF*VAR*…. Then step 3 becomes useful:

```
export TF_VAR_function="sminstall"
export TF_VAR_product_name="Nonfed-SM"
export TF_VAR_environment="dit"
# …
terraform plan  -var-file=dit.tfvars

```

Bottom line

- If our dit.tfvars includes every variable our module needs, we can skip exporting TF_VARs
  entirely.
- If we’d rather keep secrets or common values out of those files, export them in our shell or
  use a Vault/Secrets Manager integration, and leave only the bare network info in \*.tfvars.

Either way—“cd to env + -backend-config + -var-file” is the core workflow; setting TF_VARs is just an optional convenience layer on top.

---

## 4. Prepare Backend Config

Your state lives in S3 + DynamoDB under `backends/aws-aim/dit`. From the module folder run:

```bash
terraform init \
  -backend-config=../../../backends/aws-aim/dit
```

That wires up:

- **S3 bucket**: `aim-dit-terraform-state-bucket`
- **Key**: `sminstall/dit/terraform.tfstate`
- **Lock table**: `aim-dit-terraform-state-lock`

---

## 5. Plan & Apply

```bash
terraform plan \
  -var-file=dit.tfvars \
  -out=plan.out

terraform apply plan.out
```

This will:

1. Provision N EC2 instances with your AMI, subnet, SG, volumes, tags
2. Bootstrap each via `user_data` (hostname, OS patch, etc.)
3. **(If enabled)** trigger Ansible Controller job

---

## 6. Verify

- **AWS Console** → EC2 → verify your instances and tags
- **SSH** into one using your `key_name` and its private IP
- Check `/etc/hostname` and `/etc/hosts` for correct entries
- (If Ansible was enabled) check your Controller for job success

---

## 7. (Optional) Jenkins Pipeline

Below is a sample `Jenkinsfile` you can store alongside your Terraform code to automate this end-to-end. Adjust credentials & paths as needed:

```groovy
pipeline {
  agent any
  environment {
    AWS_CREDENTIALS = credentials('aws-poweruser')
    TF_VAR_ansible_repo = 'git@bitbucket.org:your_org/ec2vms-playbook.git'
    TF_VAR_ansible_token = credentials('ansible-token')
    TF_VAR_webex_token   = credentials('webex-token')
    TF_VAR_webex_room_id = credentials('webex-room-id')
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Terraform Init') {
      steps {
        dir('terraform/aws/modules/nonfed/sminstall/dit') {
          sh 'terraform init -backend-config=../../../backends/aws-aim/dit'
        }
      }
    }
    stage('Terraform Plan') {
      steps {
        dir('terraform/aws/modules/nonfed/sminstall/dit') {
          sh 'terraform plan -var-file=dit.tfvars -out=plan.out'
        }
      }
    }
    stage('Terraform Apply') {
      steps {
        dir('terraform/aws/modules/nonfed/sminstall/dit') {
          sh 'terraform apply -auto-approve plan.out'
        }
      }
    }
    // Optional drift detection
    stage('Drift Detection') {
      steps {
        dir('terraform/aws/modules/nonfed/sminstall/dit') {
          script {
            def rc = sh(script: 'terraform plan -detailed-exitcode -var-file=dit.tfvars || true', returnStatus: true)
            if (rc == 2) {
              error("⚠️ Drift detected in DIT environment!")
            }
          }
        }
      }
    }
  }
  post {
    success {
      echo '✔️ Deployment succeeded'
    }
    failure {
      echo '❌ Deployment failed'
    }
  }
}
```

---

## 8. Rolling to Other Envs

Repeat steps **3–5** for each of `fit`, `iat`, `ipe`, `uat`, `prod`:

```bash
export TF_VAR_environment="fit"
cd terraform/aws/modules/nonfed/sminstall/fit
terraform init -backend-config=../../../backends/aws-aim/fit
terraform apply -var-file=fit.tfvars -auto-approve
```

---

### Notes & Tips

- **Clean-install mode**: if you commented out Ansible & Webex bits, no Controller interaction occurs.
- **Restoring Ansible**: re-export `TF_VAR_ansible_repo`, `TF_VAR_ansible_token`, etc., and re-enable those lines in `userdata.tpl` (or remove the comments).
- **Secrets**: use Ansible Vault for playbook credentials, and Jenkins credentials or AWS Secrets Manager for TF vars.

This end-to-end guide should get you from Mac → AWS EC2 → (optionally) Ansible Controller in a repeatable, automated pipeline.

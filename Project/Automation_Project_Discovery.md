# Project Overview and Details

As part of our infrastructure automation initiative, we need a modular Terraform codebase that can spin up a variety of AWS VMs across four environments (DEV, QA, UAT, PROD).

## Scope of work:

### Modular Terraform

- Separate, reusable modules for each component—starting with a VM provisioner.

- Environment support: DEV, QA, UAT, PROD

- Configuration management via Ansible playbooks, executed through Ansible Controller or Jenkins (Need to be
  decide after how's techincal integration goes of either ways and unk own challenges)

### Environment-specific configuration

- Per-environment .tfvars files (e.g. dev.tfvars, qa.tfvars, uat.tfvars, prod.tfvars).

### EC2 UserData injection

- Embed bootstrap scripts to download/run Ansible playbooks immediately after instance launch.

### Pipeline orchestration

1. Terraform apply to provision VMs.

2. Pause/resume control: halt further Terraform steps until Ansible completes (via Jenkins or Ansible
   Controller).

3. Trigger Ansible runs post-provisioning.

### Notifications

- Send alerts to designated Webex groups:

  - After VM provisioning.
  - After Software / Components installation finishes.
  - Any failed scenarios as well.

### Deliverables

- Clear directory layout (root-level environment folders + shared modules).

- Example Software VM module detailing AMI selection, networking, IAM roles, tagging, etc.

- CI/CD pipeline YAML/Jenkinsfile showcasing the apply → pause → Ansible → notify workflow.

### Analysis & Best Practices

- Coverage of greenfield vs. brownfield scenarios.

- Feasibility assessment, pros & cons, and recommended patterns for long-term maintainability.

## Suggested Approach and Project Structure

### 1. Terraform Modules Structure

```bash
aim-terraform-environments/
└── aim-infra-terransible/             # Root of this infra+automation project
    ├── ansible/                       # All Ansible-related code
    │   ├── inventory/
    │   │   └── aws-ec2_plugin.yml     # Dynamic AWS EC2 inventory plugin config (multi-region)
    │   └── playbooks/
    │       ├── fed/                   # Playbooks for “fed” component
    │       │   └── siteminder/
    │       │       └── siteminder.yml # Playbook to install/configure SiteMinder in fed envs
    │       └── nonfed/                # Playbooks for “nonfed” component
    │           └── siteminder/
    │               └── siteminder.yml # Playbook to install/configure SiteMinder in nonfed envs
    │
    ├── backends/                      # Plain backend-config files for Terraform state
    │   └── aws-aim/
    │       ├── dit                    # S3/DynamoDB config for DIT environment
    │       ├── fit                    # S3/DynamoDB config for FIT environment
    │       ├── iat                    # S3/DynamoDB config for IAT environment
    │       ├── ipe                    # S3/DynamoDB config for IPE environment
    │       ├── uat                    # S3/DynamoDB config for UAT environment
    │       └── prod                   # S3/DynamoDB config for PROD environment
    │
    ├── terraform/                     # Terraform code
    │   └── aws/
    │       └── modules/               # Reusable Terraform modules
    │           ├── fed/               # Placeholder module for federal component
    │           │   └── README.md      # Docs for the fed module
    │           │
    │           └── nonfed/            # Modules for “nonfed” component
    │               └── sminstall/     # “sminstall” module spins up EC2 + runs Ansible
    │                   ├── main.tf    # Core EC2 + volume + user_data resource definitions
    │                   ├── launch_ansible_job.tf # Triggers Ansible Controller job via REST API
    │                   ├── userdata.tpl         # Script to set hostname & update /etc/hosts
    │                   ├── variables.tf         # Module inputs (env, AMI, sizes, tokens…)
    │                   ├── outputs.tf           # Exposes instance IDs, IPs, hostnames
    │                   │
    │                   ├── dit/                 # DIT environment wrapper
    │                   │   ├── versions.tf      # Pins Terraform & AWS provider versions
    │                   │   ├── main.tf          # Calls the sminstall module with DIT vars
    │                   │   └── dit.tfvars       # DIT-specific values (AMI, counts, subnets…)
    │                   ├── fit/                 # FIT environment wrapper
    │                   │   ├── versions.tf
    │                   │   ├── main.tf
    │                   │   └── fit.tfvars
    │                   ├── iat/                 # IAT environment wrapper
    │                   │   ├── versions.tf
    │                   │   ├── main.tf
    │                   │   └── iat.tfvars
    │                   ├── ipe/                 # IPE environment wrapper
    │                   │   ├── versions.tf
    │                   │   ├── main.tf
    │                   │   └── ipe.tfvars
    │                   ├── uat/                 # UAT environment wrapper
    │                   │   ├── versions.tf
    │                   │   ├── main.tf
    │                   │   └── uat.tfvars
    │                   └── prod/                # PROD environment wrapper
    │                       ├── versions.tf
    │                       ├── main.tf
    │                       └── prod.tfvars
    │
    └── runbook.md                     # Markdown runbook with step-by-step instructions
```

### How to read this:

- ansible/

  - inventory/ holds our dynamic EC2 inventory plugin YAML.

  - playbooks / organizes playbooks by component (fed, nonfed), each in its own siteminder / folder.

- backends/

  - Plain files (no .tf extension) that Terraform’s -backend-config flag consumes at init time, one per
    environment.

- terraform/aws/modules/

  - fed/ for federal modules (placeholder).
  - nonfed/sminstall/ contains the reusable module to spin up EC2s and trigger Ansible, with subfolders for
    each environment (dit, fit, etc.).

- Environment wrapper folders (dit/, fit/, …)

  - versions.tf pins provider versions.

  - main.tf calls the parent module.

  - \*.tfvars hold that environment’s values.

- runbook.md

  - A “how-to” guide for setting up AWS CLI, running Terraform, and verifying Ansible runs.

### Per‐Env Backend Config Files

- Why we need per env backend config files ?

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
  -backend-config="dynamodb_table=aim-dit-terraform-state-lock" \
  -backend-config="region=us-east-1"

```

3. Why This Works

- Separate buckets per env prevent state collisions.

- Separate lock tables per env avoid “lost lock” issues when multiple envs share an account.

- We keep the same Terraform code (modules, .tf files) and just point to a different backend each time.

### Summary for backends.tf and stae lock

- Yes, use per-env bucket and lock names.

- Keep one set of .tf files; just swap the backend-config.

- This cleanly isolates our DIT, FIT, IAT, PROD, UAT states while all or some of envs in the same AWS account.

### 2. Module (sm) Design

- Define EC2 instance resource with parameters from variables (AMI, instance type, subnet,
  security groups).

- Inject UserData script using templatefile("userdata.sh.tpl", {...}) which includes:

  - Installing Ansible
  - Running the SiteMinder playbook
  - Webex notifications after VM is ready and after SiteMinder installation

- Outputs: instance ID, host/private IP, etc.

### 3. UserData Script (userdata.sh.tpl)

- A bash script template that:
  - Updates instance, installs Ansible.
  - Pulls SiteMinder Ansible playbook from a bitbucket repo or S3 or Ansible E contorller, once
    EC2's VMs are ready and available.
  - Runs the playbook locally(Without CI-CD in place phase) or jenkins or triggers Ansible
    E Controller (if used).
  - Uses Webex Teams API curl commands to send notification messages.
  - Optionally can notify Terraform or a pipeline endpoint that install finished.

### 4. Pipeline / Terraform Workflow

- Run terraform apply for VM provisioning.
- Terraform applies, and EC2s spin up running UserData.
- UserData triggers Ansible install + sends "VM ready" notification.
- Terraform can't wait for Ansible finish by itself. So, pipeline should:
  - After Terraform success, pause or wait for a webhook/callback or manual approval before
    continuing.
  - Trigger next pipeline step or external script that: - Waits/checks Ansible install completion (can be notified via Webex or a status
    endpoint). - Sends final notification when SiteMinder install completes.

### 5. Notification via Webex

- Use Webex Teams Bot with an access token
- Curl POST to Webex API to send messages to specific groups (one for each environment).
- This can be called inside UserData script after steps or called externally via pipeline script.

* ansible and webex snippets

```bash
#!/bin/bash
# Install Ansible and dependencies
yum update -y
amazon-linux-extras install ansible2 -y

# Clone or fetch SiteMinder Ansible playbook
git clone ${ansible_repo} /tmp/siteminder-playbook

# Run SiteMinder Ansible playbook
ansible-playbook /tmp/siteminder-playbook/site-minder.yml

# Notify Webex group VM is ready
curl -X POST \
  -H "Authorization: Bearer ${webex_token}" \
  -H "Content-Type: application/json" \
  -d '{"roomId":"${webex_room_id}","text":"SiteMinder VM on ${environment} is ready and playbook started."}' \
  https://webexapis.com/v1/messages

# After playbook finishes, send completion notification
curl -X POST \
  -H "Authorization: Bearer ${webex_token}" \
  -H "Content-Type: application/json" \
  -d '{"roomId":"${webex_room_id}","text":"SiteMinder installation on ${environment} completed successfully."}' \
  https://webexapis.com/v1/messages

```

### How to handle pipeline coordination?

- Option 1: Use Terraform null_resource with local-exec or remote-exec provisioners
  to trigger

- Option 2: Use Terraform purely for infrastructure, then a separate Ansible pipeline
  triggered by Terraform output or webhook.

- Option 3: Use pipeline orchestration (e.g., Jenkins, GitHub Actions) to:
  _ Run Terraform apply
  _ Wait for instances to be ready (poll or wait for Webex msg)
  _ Trigger Ansible playbook
  _ Wait for Ansible completion \* Send final notification

## Summary

- Use Terraform modules for SiteMinder EC2 provisioning with environment configs.
- Use UserData scripts with embedded Ansible run and Webex notifications.
- Manage pipeline orchestration outside Terraform for clean separation.
- Send notifications via Webex API calls from UserData or pipeline scripts.

### Recommendation for Triggering Ansible Pipeline (Optional)

- If we don’t want to rely solely on UserData, we can:

  - Let Terraform provision EC2s
  - Terraform outputs IPs or hostnames
  - CI/CD tool (like Jenkins/GitOps) reads Terraform output
  - Triggers a separate Ansible playbook runner pipeline (against the new hosts)
  - Sends Webex notifications after each phase

### Optional: CI/CD Ansible Trigger Instead of UserData?

- If we want to:
  - Let Terraform finish and output IPs.
  - Then trigger Ansible via Jenkins : Here's a clean, production-ready setup where: 1. Terraform provisions SiteMinder VMs and outputs their IPs. 2. Jenkins picks up those IPs and runs Ansible to install SiteMinder. 3. Jenkins sends a Webex notification once the installation completes.

### Step 1: Finalize Terraform Output

Make sure your outputs.tf in the module (or in env/dit/main.tf level) includes:

```bash
output "sm_vm_ips" {
  description = "Private IPs of SiteMinder VMs"
  value       = [aws_instance.sm_vm[*].private_ip]
}
```

Run terraform apply, then export IPs using:

```bash
terraform output -json sm_vm_ips | jq -r '.[]' > sm_vm_ips.txt

```

### Step 2: Jenkins Pipeline (Jenkinsfile)

Create this in our infra-pipelines/ folder:

```bash
pipeline {
  agent any

  environment {
    ANSIBLE_REPO = 'https://github.com/your-org/siteminder-ansible.git'
    INVENTORY_FILE = 'inventory/sm_hosts.ini'
    WEBEX_TOKEN = credentials('webex_token')
    WEBEX_ROOM  = credentials('webex_room_id')
  }

  stages {
    stage('Fetch Terraform Outputs') {
      steps {
        sh '''
          cd terraform/aws/envs/dit
          terraform output -json sm_vm_ips | jq -r '.[]' > /tmp/sm_vm_ips.txt
        '''
      }
    }

    stage('Prepare Ansible Inventory') {
      steps {
        sh '''
          echo "[siteminder]" > ${INVENTORY_FILE}
          cat /tmp/sm_vm_ips.txt >> ${INVENTORY_FILE}
        '''
      }
    }

    stage('Clone Ansible Repo') {
      steps {
        git url: "${env.ANSIBLE_REPO}"
      }
    }

    stage('Run Ansible Playbook') {
      steps {
        sh '''
          ansible-playbook -i ${INVENTORY_FILE} site-minder.yml
        '''
      }
    }

    stage('Notify Webex') {
      steps {
        sh '''
          curl -X POST \
            -H "Authorization: Bearer ${WEBEX_TOKEN}" \
            -H "Content-Type: application/json" \
            -d "{\"roomId\":\"${WEBEX_ROOM}\",\"text\":\"✅ SiteMinder successfully installed on VMs in DIT.\"}" \
            https://webexapis.com/v1/messages
        '''
      }
    }
  }

  post {
    failure {
      sh '''
        curl -X POST \
          -H "Authorization: Bearer ${WEBEX_TOKEN}" \
          -H "Content-Type: application/json" \
          -d "{\"roomId\":\"${WEBEX_ROOM}\",\"text\":\"❌ SiteMinder installation failed in DIT. Check Jenkins logs.\"}" \
          https://webexapis.com/v1/messages
      '''
    }
  }
}

```

### Notes

- Jenkins needs:

  - ansible installed (ansible-playbook CLI)
  - AWS credentials if fetching TF output from remote backend
  - jq installed to parse TF output

- You may want to commit inventory/sm_hosts.ini to .gitignore

### Questions -

- Would it be possible to have Ansible Controller invoke the playbook immediately after the
  Terraform job completes rather than using Jenkins? Or, Alternatively, can we configure a Jenkins trigger directly from within the Ansible Controller playbook?

* Ans : Yes, both options are absolutely possible, and here's how you can choose and implement
  either approach based on which architecture will go:

### ✅ Option 1: Trigger Ansible Controller Job Template from Terraform Output

- You can trigger a job template on Red Hat Ansible Automation Controller (formerly Tower) after
  Terraform completes — using:
  - Ansible Controller REST API (triggered via curl)
  - A script or tool like tower-cli or awx CLI
  - Webhook trigger if your Ansible Controller supports it

#### 🔧 How to Trigger from Terraform (using local-exec provisioner)

- In our Terraform config (in env like dit/main.tf):

```bash
resource "null_resource" "trigger_ansible" {
  provisioner "local-exec" {
    command = <<EOT
curl -k -X POST https://ansible-controller.yourdomain.com/api/v2/job_templates/42/launch/ \
  -H "Authorization: Bearer ${var.ansible_token}" \
  -H "Content-Type: application/json" \
  -d '{"extra_vars": {"env": "${var.environment}", "target_ips": ${jsonencode(module.spin_new_vms.sm_vm_ips)}}}'
EOT
  }

  depends_on = [module.spin_new_vms]
}

```

We'll need to :

- Store ansible_token securely (Ansible Vault not viable soltuion / Hashicorp Vault / AWS
  Secrets).
- Pass IPs as extra_vars (target_ips) into your playbook via Ansible Controller

### ✅ Option 2: Let Ansible Controller Trigger Jenkins (reverse flow)

- If we prefer to:

  - Have Ansible Controller handle all orchestration,
  - But trigger a Jenkins job at the end, for example, to deploy monitoring or compliance checks.

- We can use Ansible Controller’s uri module inside the playbook:

#### 🔧 SM Sample Playbook Snippet:

```bash
- name: Trigger Jenkins Job
  uri:
    url: "https://jenkins/job/sm-post-deploy/buildWithParameters"
    method: POST
    user: "{{ jenkins_user }}"
    password: "{{ jenkins_token }}"
    force_basic_auth: yes
    status_code: 201
    body_format: form-urlencoded
    body:
      env: "{{ env }}"
      vm_ips: "{{ hostvars[inventory_hostname]['ansible_host'] }}"

```

- We can securely store jenkins*token as Ansible Controller credentials if we can somewhere
  (need to find out*).

### Recommended Architecture for Current Landscape

- Since we've already spinning up infra with Terraform and want to install SM via
  Ansible, the cleanest, most automated flow would be:

#### 💡 Best Practice: Terraform ➝ Trigger Ansible Controller Job Template via REST

```bash
[Bitbucket / Jenkins]
     |
     v
Terraform spins VMs ➝ Outputs IPs ➝
     |
     v
Triggers Ansible Controller Job Template via API ➝
     |
     v
Ansible Playbook installs SiteMinder ➝ Sends Webex Notification

```

#### This:

- Separates provisioning (Terraform) from configuration (Ansible).
- Allows modular CI/CD pipelines.
- Scales cleanly to DIT/FIT/IAT/PROD.

#### 🧩 Details:

- backends/aws-""/{env}/backend.tf
  Defines S3/DynamoDB backend per environment.
- terraform/aws/envs/{env}
  Where you reference the module spin_new_vms and configure specific variables.
- terraform/aws/modules/spin_new_vms/
  Contains reusable logic to spin up EC2s, install SiteMinder, run userdata.tpl.
- ansible/site-minder.yml
  The playbook to run from Ansible Controller after Terraform finishes.

#### 🔄 Flow:

1. terraform init from terraform/aws/envs/dev using backend from backends/aws-mitcloud/dev/
2. Run terraform apply → Get VM IPs.
3. Trigger Ansible Controller Job Template (via API or CLI).
4. Job runs site-minder.yml playbook.
5. Webex notification via webhook in final task.

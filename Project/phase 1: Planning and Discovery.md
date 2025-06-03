## Phase 1: Planning & Discovery\*\*

### 1. Project Overview

We’re building an end-to-end automation framework to spin up SiteMinder servers in AWS across multiple environments (DIT, FIT, IAT, IPE, UAT, PROD) and configure them via Ansible Automation Controller. This will standardize our infrastructure, improve repeatability, and accelerate our release cycles.

---

### 2. Objectives

- Define a reusable Terraform module (`sminstall`) that:

  - Provisions EC2 instances (root + secondary EBS volumes) in existing VPC, subnets & security groups
  - Tags instances and volumes consistently (`Name`, `Prefix`, `Environment`)
  - Sets OS hostnames and updates `/etc/hosts` dynamically

- Structure environment-specific wrappers (`dit/`, `fit/`, etc.) for isolated state
- Integrate with Ansible Controller:

  - Dynamic EC2 inventory (private-only IPs)
  - Job template trigger via Terraform

- Organize Ansible playbooks under `ansible/playbooks/{fed,nonfed}/siteminder`

---

### 3. Key Deliverables Last & This Week from bitbucket branch which integrate with JIRA.

| Item                              | Status | Notes                                                                                                                         |
| --------------------------------- | :----: | ----------------------------------------------------------------------------------------------------------------------------- |
| **Terraform “sminstall” module**  |   ✅   | `main.tf`, `variables.tf`, `outputs.tf`, `userdata.tpl` (Ansible logic excluded), `launch_ansible_job.tf` configured & tested |
| **Environment wrappers**          |   ✅   | Folders for DIT, FIT, IAT, IPE, UAT, PROD each include `versions.tf`, `main.tf`, `<env>.tfvars`.                              |
| **Backend strategy**              |   ✅   | Centralized `backends/aws-aim/{env}` files; invoked via `terraform init -backend-config`.                                     |
| **Ansible inventory & playbooks** |   ✅   | Dynamic AWS EC2 plugin YAML in inventory; playbooks under `fed/` and `nonfed/` scopes (Placeholder designed).                 |
| **Jenkins pipeline (PoC)**        |   ✅   | Bitbucket-checkout pipeline that runs Terraform, triggers Ansible, sends Webex notifications.                                 |
| **Runbook documentation**         |   ✅   | Step-by-step instructions for Mac-based engineers to spin up and verify.                                                      |

---

### 4. Architectural Highlights

- **Module Reusability**
  All core compute, tagging, UserData and Ansible-trigger logic lives in `terraform/aws/modules/nonfed/sminstall`, with no backend code.
- **State Management**
  Backends defined once under `backends/aws-aim/{env}`, consumed via `-backend-config`.
- **Hostname & Tag Sync**
  Terraform tags & OS hostname share the same format:

  ```
  ${var.function}-${count.index}.${var.environment}.${var.product_name}.${availability_zone}
  ```

  ### Why that order?

  1. Host first makes it easy to do reverse lookups (dig -x).
  2. Environment next (dit, fit, prod, etc.) groups all like-hosts under one subdomain.
  3. Region/AZ last (use1a) keeps your internal FQDN under your normal company-domain (aim).

  - If we're added to below host pattern, it still works, but most tools and conventions expect
    hostname up front.

  ```
  ${availability_zone}.${var.environment}.${var.product_name}.${var.function}-${count.index}
  ```

  - Hostnames ultimately need to conform to DNS and OS expectations, and consistency is more
    important than any particular capitalization style.

    1. Follow the DNS/RFC rules -

       - Hostnames must match the DNS “label” rules (RFC 952, updated by RFC 1123):
         - Only ASCII letters a–z, digits 0–9 and hyphens (-)
         - Cannot begin or end with a hyphen
         - Maximum 63 characters per label (255 characters total for FQDN)

    2. Use lowercase only
       - Although DNS comparisons are case-insensitive, many tools, scripts, and configuration
         management systems make assumptions about lowercase names.
       - Mixing uppercase can lead to subtle bugs (e.g. tools that convert hostnames to
         lowercase when looking up inventory).

  - Bottom Line - Always use lowercase, hyphen-separated labels that reflect your service/
    component, environment, and instance number.

- **Ansible Integration**
  Private-only dynamic inventory across regions; playbooks organized by component in project layout.

- **Orchestration**
  Terraform → Ansible Controller launch via REST API in a `null_resource`, wrapped by Jenkins.

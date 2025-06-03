
# Jenkins Setup Guide for Terraform Enterprise Infra

This document provides steps for Jenkins admins to configure secure credentials and enable CI/CD automation for the Terraform project.

---

## 🔐 Secure Credentials Setup

### 1. Bitbucket Git Credentials

Used to access your Bitbucket repository in multibranch pipelines.

**Steps:**
1. Navigate to **Jenkins UI** → `Manage Jenkins` → `Credentials`
2. Select `(global)` → `Add Credentials`
3. Configure:
   - **Kind**: `Username with password`
   - **Username**: your Bitbucket username
   - **Password**: your Bitbucket App Password
   - **ID**: `bitbucket-cred-id`
   - **Description**: `Bitbucket Terraform Infra Access`
4. Click `OK`

> This ID is used in the `jenkins/job-dsl/terraform_multibranch.groovy` script.

---

### 2. Webex Webhook Credentials

Used to send failure alerts from Jenkins pipelines.

**Steps:**
1. Go to **Jenkins UI** → `Manage Jenkins` → `Credentials`
2. Select `(global)` → `Add Credentials`
3. Configure:
   - **Kind**: `Secret text`
   - **Secret**: Full Webex incoming webhook URL
   - **ID**: `webex-webhook-url`
   - **Description**: `Webex Alert Webhook`
4. Click `OK`

> Referenced in shared library: `terraformLib.groovy`

---

## 🚀 Jenkins Seed Job Setup

### Job DSL

The seed job can automatically import and create a multibranch pipeline job from Bitbucket:

**Path:** `jenkins/job-dsl/terraform_multibranch.groovy`

**Steps:**
1. Create a **Freestyle seed job**.
2. Add a `Process Job DSLs` step:
   - DSL script location: `jenkins/job-dsl/**/*.groovy`
3. Save and build the seed job to auto-create your main pipeline.

---

## 🧱 Shared Library Setup

1. In Jenkins UI → `Manage Jenkins` → `Configure System`
2. Scroll to `Global Pipeline Libraries`
3. Add new entry:
   - **Name**: `terraform-lib`
   - **Default Version**: `main`
   - **Retrieval method**: Modern SCM
   - **Source**: Git
   - **Project repository**: `https://bitbucket.org/your-org/terraform-enterprise-infra.git`
   - **Credentials ID**: `bitbucket-cred-id`

This enables every `Jenkinsfile` in modules to call:

```groovy
@Library('terraform-lib@main') _
```

And reuse shared steps like:
- `terraformSetup()`
- `terraformPlanApply()`
- `sendWebexNotification("...")`

---

## 📦 Final Notes

- Secrets are securely injected via `withCredentials` block.
- All modules include `Jenkinsfile` for multibranch compatibility.
- Webex alerts only trigger on pipeline failure.

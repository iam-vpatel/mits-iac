Here is a clean and professional **README onboarding guide** for Jenkins Admins to set up and manage the Terraform infrastructure CI/CD pipeline:

---

# 📘 Jenkins Admin Onboarding Guide: Terraform Enterprise Infra

This guide walks Jenkins admins through setting up credentials, seed jobs, shared libraries, and Webex integration to enable CI/CD automation for the Terraform infrastructure modules.

---

## 🔐 Step 1: Set Up Secure Credentials

### ➤ 1.1 Bitbucket Credentials (for Git integration)

Used for cloning the Bitbucket repo in multibranch pipelines.

1. Go to **Jenkins Dashboard** → `Manage Jenkins` → `Credentials` → `(global)` → `Add Credentials`
2. Select:

   - **Kind**: `Username with password`
   - **Username**: Bitbucket username
   - **Password**: Bitbucket **App Password**
   - **ID**: `bitbucket-cred-id`
   - **Description**: `Bitbucket Terraform Infra Access`

3. Click **OK**

🔗 Used in:

- `jenkins/job-dsl/terraform_multibranch.groovy`
- Shared library Git access

---

### ➤ 1.2 Webex Webhook Credential (for notifications)

Used to send build failure notifications to Webex Teams.

1. Go to `Manage Jenkins` → `Credentials` → `(global)` → `Add Credentials`
2. Select:

   - **Kind**: `Secret text`
   - **Secret**: Webex webhook URL (e.g., `https://webexapis.com/v1/webhooks/incoming/...`)
   - **ID**: `webex-webhook-url`
   - **Description**: `Webex Notification URL`

3. Click **OK**

🔗 Used in:

- `terraformLib.groovy` inside shared library

---

## 🚀 Step 2: Create Seed Job for Multibranch Pipelines

1. Create a **new Freestyle job** called `terraform-seed`
2. Add a **"Process Job DSLs"** build step
3. DSL script location:

   ```
   jenkins/job-dsl/**/*.groovy
   ```

4. Save and **Build Now**

📄 This creates a multibranch job: `terraform-enterprise-infra` that auto-detects module-level `Jenkinsfile` pipelines.

---

## 🧱 Step 3: Configure Jenkins Shared Library

1. Go to `Manage Jenkins` → `Configure System`
2. Scroll to **Global Pipeline Libraries**
3. Add new library:

   - **Name**: `terraform-lib`
   - **Default Version**: `main`
   - **Project Repository**: `https://bitbucket.org/your-org/terraform-enterprise-infra.git`
   - **Credentials ID**: `bitbucket-cred-id`
   - **Retrieval method**: Modern SCM → Git

🔗 Used in every module's `Jenkinsfile` like:

```groovy
@Library('terraform-lib@main') _
```

---

## 🔁 Step 4: Verify Each Terraform Module

Each `modules/*` directory includes:

- ✅ A dedicated `Jenkinsfile`
- ✅ Calls to shared library steps like:

  ```groovy
  terraformSetup()
  terraformPlanApply()
  sendWebexNotification("Job failed: ${env.JOB_NAME}")
  ```

---

## 📬 Step 5: Confirm Webex Alerts Work

Webex alerts are triggered in pipeline `post { failure { ... } }` blocks.

Make sure:

- The Webex webhook credential is configured
- Your Webex room allows incoming bot messages

---

## ✅ Final Checklist

| Task                                         | Status        |
| -------------------------------------------- | ------------- |
| Bitbucket Credential `bitbucket-cred-id`     | ✅ Setup      |
| Webex Webhook Credential `webex-webhook-url` | ✅ Setup      |
| Seed job for `terraform_multibranch`         | ✅ Created    |
| Shared Library `terraform-lib` configured    | ✅ Integrated |
| Multibranch pipelines triggered              | ✅ Active     |

---

Let me know if you'd like this formatted into a PDF, Confluence export, or internal wiki format.

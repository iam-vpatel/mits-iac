Here’s how to securely set up **Jenkins credentials** for both **Bitbucket Git integration** and **Webex webhook notifications**, using Jenkins' built-in credential management:

---

## ✅ 1. **Bitbucket Git Integration (HTTPS with Username + App Password)**

### 🔐 Steps:

1. **Go to Jenkins UI** → `Manage Jenkins` → `Credentials`
2. Choose: `(global)` → `Add Credentials`
3. Set:

   - **Kind**: `Username with password`
   - **Username**: your Bitbucket username
   - **Password**: your Bitbucket App Password (not actual password)
   - **ID**: `bitbucket-cred-id`
   - **Description**: `Bitbucket Terraform Infra Access`

4. Click `OK`

> ✅ Use `bitbucket-cred-id` in Job DSL or Jenkinsfile:

```groovy
credentialsId('bitbucket-cred-id')
```

---

## ✅ 2. **Webex Webhook Integration (as Secret Text)**

### 🔐 Steps:

1. **Go to Jenkins UI** → `Manage Jenkins` → `Credentials`
2. Choose: `(global)` → `Add Credentials`
3. Set:

   - **Kind**: `Secret text`
   - **Secret**: your full Webex incoming webhook URL
     (e.g., `https://webexapis.com/v1/webhooks/incoming/XXXXX`)
   - **ID**: `webex-webhook-url`
   - **Description**: `Webex Alert Webhook`

4. Click `OK`

> ✅ Update your **shared library** to fetch the webhook securely:

```groovy
def sendWebexNotification(message) {
  withCredentials([string(credentialsId: 'webex-webhook-url', variable: 'WEBEX_URL')]) {
    sh """
      curl -X POST -H 'Content-Type: application/json' \
      -d '{"text": "${message}"}' $WEBEX_URL
    """
  }
}
```

---

## 📦 Optional: Add Credential via Script (Groovy Console)

```groovy
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import hudson.util.Secret

def store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

// Bitbucket credentials
def bitbucketCred = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,
    "bitbucket-cred-id",
    "Bitbucket Terraform Access",
    "your-bitbucket-username",
    "your-bitbucket-app-password"
)
store.addCredentials(Domain.global(), bitbucketCred)

// Webex webhook credential
def webexCred = new StringCredentialsImpl(
    CredentialsScope.GLOBAL,
    "webex-webhook-url",
    "Webex Alert Webhook",
    Secret.fromString("https://webexapis.com/v1/webhooks/incoming/XXXXX")
)
store.addCredentials(Domain.global(), webexCred)
```

---

Would you like a `README_Jenkins.md` file documenting these steps to include in your repo?

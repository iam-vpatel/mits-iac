
def terraformSetup() {
  sh 'terraform init'
  sh 'terraform validate'
}

def terraformPlanApply() {
  sh 'terraform plan'
  input message: "Approve apply?"
  sh 'terraform apply -auto-approve'
}

def sendWebexNotification(message) {
  def webhookUrl = "https://webexapis.com/v1/webhooks/incoming/YOUR_WEBHOOK_URL"
  sh "curl -X POST -H 'Content-Type: application/json' -d '{"text": "${message}"}' ${webhookUrl}"
}

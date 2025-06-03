# launch_ansible_job.tf

# resource "null_resource" "launch_sminstall_job" {
#   # Always re-run after any change to trigger a fresh job
#   triggers = {
#     always_run = timestamp()
#   }

#   # Wait for all instances in this module to exist
#   depends_on = [
#     aws_instance.sminstall
#   ]

#   provisioner "local-exec" {
#     command = <<-EOT
#       curl -s -k -X POST \
#         -H "Authorization: Bearer ${var.ansible_token}" \
#         -H "Content-Type: application/json" \
#         -d '{"extra_vars":{"environment":"${var.environment}"}}' \
#         https://${var.ansible_controller_host}/api/v2/job_templates/${var.job_template_id}/launch/
#     EOT
#   }
# }

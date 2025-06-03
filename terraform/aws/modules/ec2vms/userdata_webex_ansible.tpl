# #!/usr/bin/env bash
# set -euo pipefail
# exec > >(tee -a /var/log/user-data.log) 2>&1

# # ─── Variables injected by Terraform via templatefile() ───
# FUNCTION="${function}"
# INDEX="${index}"
# ENV="${environment}"
# PRODUCT="${product_name}"
# ANSIBLE_REPO="${ansible_repo}"
# WEBEX_TOKEN="${webex_token}"
# WEBEX_ROOM_ID="${webex_room_id}"

# # ─── Build hostname and fetch private IP ───────────────────
# HOSTNAME="${FUNCTION}-${INDEX}.${ENV}.${PRODUCT}.${AZ}"
# PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# echo "[1/10] Setting system hostname to ${HOSTNAME}"
# echo "${HOSTNAME}" > /etc/hostname
# hostnamectl set-hostname "${HOSTNAME}"

# echo "[2/10] Ensuring /etc/hosts contains ${PRIVATE_IP} → ${HOSTNAME}"
# if ! grep -qE "^${PRIVATE_IP}[[:space:]]+${HOSTNAME}\$" /etc/hosts; then
#   echo "${PRIVATE_IP}    ${HOSTNAME}" >> /etc/hosts
# fi

# echo "[3/10] Updating OS packages"
# dnf update -y

# echo "[4/10] Installing Git and Ansible"
# dnf install -y git
# dnf install -y ansible-core

# echo "[5/10] Cloning SiteMinder playbook: ${ANSIBLE_REPO}"
# rm -rf /tmp/siteminder-playbook
# git clone "${ANSIBLE_REPO}" /tmp/siteminder-playbook

# echo "[6/10] Notifying Webex: playbook starting"
# curl -s -X POST \
#   -H "Authorization: Bearer ${WEBEX_TOKEN}" \
#   -H "Content-Type: application/json" \
#   -d "{\"roomId\":\"${WEBEX_ROOM_ID}\",\"text\":\"🚀 ${HOSTNAME} (${ENV}) – starting SiteMinder playbook.\"}" \
#   https://webexapis.com/v1/messages

# echo "[7/10] Running Ansible playbook"
# /usr/bin/ansible-playbook /tmp/siteminder-playbook/siteminder.yml \
#   --extra-vars "hostname=${HOSTNAME} environment=${ENV}"

# echo "[8/10] Notifying Webex: playbook completed"
# curl -s -X POST \
#   -H "Authorization: Bearer ${WEBEX_TOKEN}" \
#   -H "Content-Type: application/json" \
#   -d "{\"roomId\":\"${WEBEX_ROOM_ID}\",\"text\":\"✅ ${HOSTNAME} (${ENV}) – SiteMinder installation complete.\"}" \
#   https://webexapis.com/v1/messages

# echo "[9/10] Cleaning up"
# rm -rf /tmp/siteminder-playbook

# echo "[10/10] User-data bootstrap finished"

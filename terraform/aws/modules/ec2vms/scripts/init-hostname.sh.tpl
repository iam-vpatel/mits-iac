# terraform/aws/modules/ec2vms/scripts/init-hostname.sh.tpl
#!/usr/bin/env bash
set -euxo pipefail
exec > >(tee -a /var/log/user-data.log) 2>&1

FUNCTION="${function}"
ENV="${environment}"
PREFIX="${prefix_name}"
INDEX=${index}

HOSTNAME="${PREFIX}-${ENV}-${FUNCTION}-${INDEX}"
echo "[1/3] Setting hostname to ${HOSTNAME}"
echo "${HOSTNAME}" > /etc/hostname
hostnamectl set-hostname "${HOSTNAME}"

IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "[2/3] Adding ${IP} ↔ ${HOSTNAME} to /etc/hosts"
if ! grep -qE "^${IP}[[:space:]]+${HOSTNAME}\$" /etc/hosts; then
  echo "${IP}    ${HOSTNAME}" >> /etc/hosts
fi

echo "[3/3] Hostname setup complete"

# #!/bin/bash

# # Set the hostname from Terraform variable
# hostnamectl set-hostname ${hostname}

# # Fetch and export the private IP address
# PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
# export PRIVATE_IP

# # Run any additional user data script if needed
# bash ${path.module}/userdata_additional.sh || true
# ────────────────────────────
# Core Environment & Naming
# ────────────────────────────

variable "environment" {
  description = "Environment name (e.g. dit, fit, iat)"
  type        = string
}

variable "function" {
  description = "Function name used in hostnames (e.g. siteminder)"
  type        = string
}

variable "prefix_name" {
  description = "Product prefix for naming and tagging (e.g. Nonfed-SM)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "account_no" {
  description = "AWS account number (for cross-account references, if needed)"
  type        = string
  default     = ""
}

# ────────────────────────────
# EC2 / Networking
# ────────────────────────────

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (e.g., t3.micro)"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to launch"
  type        = number
}

variable "subnet_id" {
  description = "ID of an existing Subnet to launch EC2 instances into"
  type        = string
}

variable "security_group_id" {
  description = "ID of an existing Security Group to attach to instances"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 Key Pair for SSH access"
  type        = string
}

variable "iam_instance_profile" {
  description = "Name of an existing IAM Instance Profile to attach"
  type        = string
}

# ────────────────────────────
# EBS Volume Configuration
# ────────────────────────────

variable "root_volume_size" {
  description = "Size (GiB) of the root EBS volume"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Type of the root EBS volume (e.g., gp3, gp2, io1)"
  type        = string
  default     = "gp3"
}

variable "root_delete_on_termination" {
  description = "Whether to delete the root volume on instance termination"
  type        = bool
  default     = true
}

variable "root_volume_encrypted" {
  description = "Whether the root EBS volume is encrypted"
  type        = bool
  default     = true
}

variable "ebs_device_name" {
  description = "Device name for the additional EBS volume"
  type        = string
  default     = "/dev/sdb"
}

variable "ebs_volume_size" {
  description = "Size (GiB) of the additional EBS volume"
  type        = number
  default     = 20
}

variable "ebs_volume_type" {
  description = "Type of the additional EBS volume (e.g., gp3, gp2, io1)"
  type        = string
  default     = "gp3"
}

variable "ebs_delete_on_termination" {
  description = "Whether to delete the additional volume on termination"
  type        = bool
  default     = true
}

variable "ebs_volume_encrypted" {
  description = "Whether the additional EBS volume is encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS Key ID or ARN for EBS encryption (null = AWS-managed key)"
  type        = string
  default     = null
}

# ────────────────────────────
# Ansible Automation Controller
# ────────────────────────────

# variable "ansible_repo" {
#   description = "Git URL of the SiteMinder Ansible playbook repository"
#   type        = string
# }

# variable "ansible_token" {
#   description = "Ansible Automation Controller API token"
#   type        = string
#   sensitive   = true
# }

# variable "ansible_controller_host" {
#   description = "FQDN of the Ansible Automation Controller"
#   type        = string
# }

# variable "job_template_id" {
#   description = "ID of the SiteMinder job template in the Controller"
#   type        = number
# }

# variable "webex_token" {
#   description = "Webex Teams API Bearer Token for notifications"
#   type        = string
#   sensitive   = true
# }

# variable "webex_room_id" {
#   description = "Webex Teams Room ID to post notifications into"
#   type        = string
# }


# Terraform Enterprise Infrastructure

This project provisions a complete AWS infrastructure setup for internal EC2 workloads with DNS, monitoring, TLS, and secure access.

## ✅ Key Features

- Private EC2 with `for_each` dynamic provisioning
- Route53 DNS (public & private zones)
- SSM access & Bastion host
- NAT Gateway for private internet access
- TLS-secured Application Load Balancer with ACM
- CloudWatch Logs & CPU alarms
- SES/SNS Email Alerts for monitoring
- GitHub Actions CI/CD for automation

## 📌 Architecture Diagram

```
                        ┌──────────────────────┐
                        │   GitHub Actions     │
                        └─────────┬────────────┘
                                  │
                            ┌─────▼─────┐
                            │ Terraform │
                            └─────┬─────┘
                                  │
                   ┌──────────────┼────────────────────┐
                   │              │                    │
          ┌────────▼───┐  ┌───────▼──────┐      ┌──────▼─────┐
          │  VPC/Subnet│  │ EC2 (Private)│      │Bastion Host│
          └─────┬──────┘  └───────┬──────┘      └──────┬─────┘
                │                │                     │
       ┌────────▼─────┐  ┌───────▼────────┐   ┌────────▼────────┐
       │ NAT Gateway  │  │ Route53 (Zone) │   │ SSM Session Mgr │
       └──────────────┘  └────────────────┘   └──────────────────┘

## 🧪 Usage

1. Fill `terraform.tfvars` with correct values.
2. Run:

```bash
terraform init
terraform apply
```

3. Check email for SNS confirmation.
4. Optional: Connect via Session Manager to private EC2.

## 🔐 CI/CD Deployment

This project includes GitHub Actions to deploy automatically on push to main. Store your AWS credentials in GitHub Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`


# Terraform Enterprise Infrastructure

This Terraform project provisions a secure, production-grade AWS infrastructure with the following features:

### ✅ Features:
- EC2 with `for_each` dynamic support in private subnets
- Bastion Host + NAT Gateway + SSM for access
- Route53 DNS (public + private)
- CloudWatch Logs and Alarms (e.g., CPU > 80%)
- TLS via ACM and Public ALB listener on port 443
- SES/SNS Email alerts on alarms
- GitHub Actions CI/CD pipeline integration

---

## 📐 Architecture Diagram

```
                          +----------------------------+
                          |        GitHub Actions      |
                          |   (Terraform CI/CD Flow)   |
                          +-------------+--------------+
                                        |
                                        v
                          +----------------------------+
                          |    Terraform Orchestration |
                          +-------------+--------------+
                                        |
                                        v
                    +---------------------------------------------+
                    |               AWS Infrastructure            |
                    |                                             |
                    |  +---------+       +------------------+     |
                    |  | Bastion | <---> | Private Subnet   |     |
                    |  +---------+       | EC2 + SSM Agent  |     |
                    |        |           +------------------+     |
                    |        |                  |                 |
                    |    Internet         +-------------+         |
                    |                     | Route53 Zone |        |
                    |                     +-------------+         |
                    |         +---------> ACM + ALB TLS  <--------+
                    |         |            + SNS Alerts           |
                    +---------+-----------------------------------+
```

---

## 🚀 CI/CD Setup
- Secrets: Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to your GitHub repo secrets
- Trigger: Pushing to `main` branch runs `init`, `validate`, `plan`, and `apply`

---

## 📧 Email Alerts
- Configured using Amazon SNS
- Sends email notifications when CPU > 80% on EC2 instances

---

## 🛠 Modules
```
modules/
├── alb_tls
├── bastion
├── cloudwatch
├── dynamic_ec2
├── nat_gateway
├── private_route53_zone
├── route53_record
├── security_group
├── ssm
├── sns_alerts
```

To enable/disable features, edit `main.tf` and adjust modules and variables accordingly.

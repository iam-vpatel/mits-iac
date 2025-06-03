Here’s a quick recipe for creating an EC2 instance profile entirely from the AWS CLI on your Mac:

1. **Install & configure the AWS CLI** (if you haven’t already):

   ```bash
   brew install awscli            # via Homebrew
   aws configure                  # set your AWS Access Key, Secret, region, output format
   ```

2. **Create a trust-policy document** that lets EC2 assume the role:

   ```bash
   cat > trust-policy.json <<EOF
   {
     "Version": "2012-10-17",
     "Statement": [{
       "Effect": "Allow",
       "Principal": { "Service": "ec2.amazonaws.com" },
       "Action": "sts:AssumeRole"
     }]
   }
   EOF
   ```

3. **Create the IAM role** using that policy:

   ```bash
   aws iam create-role \
     --role-name MitsEC2Role \
     --assume-role-policy-document file://trust-policy.json
   ```

4. **Attach any managed policies** (e.g. S3 read-only) or your own policy:

   ```bash
   aws iam attach-role-policy \
     --role-name MitsEC2Role \
     --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
   ```

5. **Create the instance profile** object:

   ```bash
   aws iam create-instance-profile \
     --instance-profile-name MitsEC2InstanceProfile
   ```

6. **Add your role to the instance profile**:

   ```bash
   aws iam add-role-to-instance-profile \
     --instance-profile-name MitsEC2InstanceProfile \
     --role-name MitsEC2Role
   ```

7. **Verify** that the instance profile exists and has your role:

   ```bash
   aws iam get-instance-profile \
     --instance-profile-name MitsEC2InstanceProfile \
     --query 'InstanceProfile.[InstanceProfileName,Roles]'
   ```

8. **Use it when launching an EC2**:

   ```bash
   aws ec2 run-instances \
     --image-id ami-0123456789abcdef0 \
     --count 1 \
     --instance-type t3.micro \
     --iam-instance-profile Name=MitsEC2InstanceProfile \
     …other options…
   ```

---

#### Notes

- The `file://` prefix in `--assume-role-policy-document` tells the CLI to read your local JSON file.
- You can replace `AmazonS3ReadOnlyAccess` with any AWS-managed policy or your own custom policy ARN.
- Instance profiles are **regional**, just like roles; be sure you’re in the right AWS region (check `aws configure get region` or use `--region`).
- If you ever need to remove the role from the profile:

  ```bash
  aws iam remove-role-from-instance-profile \
    --instance-profile-name MitsEC2InstanceProfile \
    --role-name MitsEC2Role
  ```

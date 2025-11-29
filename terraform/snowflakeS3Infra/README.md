# Snowflake S3 Integration - Terraform

Terraform configuration for AWS IAM role enabling Snowflake to access S3 processed data.

## What This Creates

- IAM Role: `snowflakeS3AccessRole` with S3 read permissions
- Trust Policy: Snowflake IAM user ARN + External ID
- S3 Access: Read-only to `processed/` prefix

## How It Works

This setup uses a **two-phase approach** because of a circular dependency:
- You need Snowflake's account ID to create the IAM role
- But you need the IAM role ARN to get Snowflake's account ID

**Solution:** Create the role with your own account ID first, then update it with Snowflake's values after creating the storage integration.

## Setup Process

### Phase 1: Create IAM Role with Your Account ID

**Goal:** Create the IAM role so you can use its ARN in Snowflake.

1. **Configure Terraform:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars`:**
   ```hcl
   awsRegion         = "us-east-1"
   yourAwsAccountId  = "123456789012"  # Your AWS account ID
   s3BucketName      = "your-bucket-name"
   s3ProcessedPrefix  = "processed/"
   
   # Leave these empty for Phase 1
   snowflakeIamUserArn = ""
   snowflakeExternalId = ""
   ```

3. **Get your AWS account ID:**
   ```bash
   aws sts get-caller-identity --query Account --output text
   ```

4. **Create the role:**
   ```bash
   terraform init
   terraform apply
   ```

   **What happens:** Terraform creates the IAM role trusting your AWS account ID. The role also gets S3 read permissions.

5. **Get the role ARN:**
   ```bash
   terraform output iam_role_arn
   ```
   Copy this ARN - you'll need it for Snowflake.

### Phase 2: Create Storage Integration in Snowflake

**Goal:** Create the storage integration so Snowflake generates its IAM user ARN.

1. **Run this SQL in Snowflake:**
   ```sql
   CREATE OR REPLACE STORAGE INTEGRATION supplyChainS3Integration
   TYPE = EXTERNAL_STAGE
   STORAGE_PROVIDER = S3
   ENABLED = TRUE
   STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::YOUR_ACCOUNT:role/snowflakeS3AccessRole'
   STORAGE_ALLOWED_LOCATIONS = ('s3://your-bucket/processed/');
   ```
   Replace `YOUR_ACCOUNT` and `your-bucket` with your actual values.

2. **Extract Snowflake's values:**
   ```bash
   export SNOWFLAKE_ACCOUNT="YOUR_ACCOUNT"
   export SNOWFLAKE_USER="your_username"
   export SNOWFLAKE_PASSWORD="your_password"
   python3 extractSnowflakeAwsAccountId.py
   ```

   **You'll get:**
   - IAM User ARN: `arn:aws:iam::987654321098:user/abc123`
   - External ID: `ACCOUNT_SFCRole=6_ExampleId=`
   - Account ID: `987654321098`

### Phase 3: Update Trust Policy with Snowflake Values

**Goal:** Update the IAM role to trust Snowflake instead of your account.

1. **Update `terraform.tfvars`:**
   ```hcl
   awsRegion         = "us-east-1"
   yourAwsAccountId  = "123456789012"  # Same as before
   s3BucketName      = "your-bucket-name"
   s3ProcessedPrefix = "processed/"
   
   # Add values from Phase 2
   snowflakeIamUserArn = "arn:aws:iam::987654321098:user/abc123"
   snowflakeExternalId = "ACCOUNT_SFCRole=6_ExampleId="
   ```

2. **Update the role:**
   ```bash
   terraform apply
   ```

   **What happens:** Terraform sees the Snowflake values are now provided. It compares the current trust policy (trusting your account) with the desired policy (trusting Snowflake). Terraform updates the role's trust policy to use Snowflake's IAM user ARN and External ID.

3. **Verify:**
   ```bash
   terraform plan
   ```
   Should show "No changes" - this means everything matches.

## Understanding the Two-Phase Logic

**Phase 1 (Empty Snowflake Values):**
- Terraform code sees: `snowflakeIamUserArn = ""`
- Terraform creates role with: `arn:aws:iam::YOUR_ACCOUNT:root`
- Result: Role exists, trusts your account

**Phase 2 (Snowflake Values Provided):**
- Terraform code sees: `snowflakeIamUserArn = "arn:aws:iam::987654321098:user/abc123"`
- Terraform updates role to: Trust Snowflake's IAM user ARN + External ID
- Result: Role now trusts Snowflake

The code automatically switches between phases based on whether Snowflake values are provided.

## Files

- `main.tf` - IAM role and policies (includes two-phase logic)
- `variables.tf` - Input variables
- `outputs.tf` - Role ARN output
- `terraform.tfvars.example` - Configuration template
- `extractSnowflakeAwsAccountId.py` - Extract account ID from storage integration
- `env.example` - Snowflake credentials template

## Quick Reference

**Phase 1:**
```bash
# Set yourAwsAccountId, leave Snowflake values empty
terraform apply
terraform output iam_role_arn  # Use this in Snowflake
```

**Phase 2:**
```bash
# Create storage integration in Snowflake
# Get values using extractSnowflakeAwsAccountId.py
# Update terraform.tfvars with Snowflake values
terraform apply  # Updates trust policy
```

## Troubleshooting

**"No changes" after Phase 3:**
- This is correct! It means the role already matches what Terraform wants.

**"Will update" after Phase 3:**
- Terraform will update the trust policy to match the code. This is expected.

**Role creation fails:**
- Make sure `yourAwsAccountId` is correct (12-digit number)
- Verify AWS credentials are configured

## Output

```bash
terraform output iam_role_arn
```

Use this ARN when creating Snowflake storage integration.

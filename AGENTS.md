# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project Overview

This repository contains Terraform infrastructure-as-code for deploying a Cyber Defense Team Forensics Lab environment in AWS. The lab provides isolated forensics workstations for security analysis and incident response activities.

## Architecture

The AWS provider uses `us-east-1` for region discovery. The root module deploys lab resources in each enabled Region returned by `data.aws_regions.avail_regions`.

**Network Layer** (`infra/modules/forensics_lab/main.tf`):
- VPC (`10.0.0.0/16`) with DNS support enabled
- Private subnet (`10.0.1.0/24`) that hosts forensics workstations with no direct internet access
- Public subnet (`10.0.2.0/24`) that hosts the NAT Gateway and VPC endpoints
- Internet Gateway for public subnet routing
- NAT Gateway for private subnet outbound connectivity
- Interface VPC endpoints for EC2, SSM, EC2Messages, SSMMessages, Logs, and KMS, plus an S3 gateway endpoint

**Compute Layer** (`infra/modules/forensics_lab/main.tf`):
- Launch template for Windows Server 2025 forensics workstations; Terraform looks up the latest matching Amazon-owned AMI in each Region
- Instance type: `c7a.8xlarge` with 500 GB encrypted GP3 storage
- The launch template configures AWS Systems Manager Session Manager access; no RDP/SSH ingress is required
- IAM instance profile references the `SessionManagerPermissions` role
- Security groups allow all outbound traffic and DNS to the VPC resolver
- User data script: `userdata.ps` (PowerShell script for instance initialization)

**Security Model**:
- Workstations launched from the template use a private subnet and no public IP addresses
- VPC endpoints provide private connectivity to configured AWS services; the private subnet also has a NAT route
- IMDSv2 is required for instance metadata access
- The VPC endpoint security group allows traffic from the workstation security group

## Common Commands

Run all Terraform commands from the `infra/` directory:

```bash
cd infra
```

Initialize Terraform (required after cloning or adding providers):

```bash
terraform init
```

Plan infrastructure changes:

```bash
terraform plan
```

Apply infrastructure changes:

```bash
terraform apply
```

Destroy infrastructure:

```bash
terraform destroy
```

Format Terraform files:

```bash
terraform fmt -recursive
```

Validate Terraform configuration:

```bash
terraform validate
```

## Important Notes

- The provider configuration requires AWS provider version `~> 6.0`.
- Terraform creates the IAM role `SessionManagerPermissions` in `infra/iam.tf`. Import an existing role with that name into Terraform state before applying.
- Terraform base64-encodes `userdata.ps` when creating the launch template.
- Terraform state files contain sensitive information and must not be committed to version control.

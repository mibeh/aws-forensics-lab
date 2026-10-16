# AWS Forensics Lab

Terraform configuration for a Windows forensics lab in AWS. It creates a network and an EC2 launch template in each AWS Region enabled for the account. It does not launch a workstation instance.

## Infrastructure

Each regional lab includes:

- A VPC with public and private subnets, an internet gateway, and a NAT gateway.
- Interface VPC endpoints for EC2, Systems Manager, EC2 Messages, SSM Messages, CloudWatch Logs, and KMS, plus an S3 gateway endpoint.
- A launch template for a Windows Server 2025 workstation in the private subnet, without a public IP address.
- An instance profile using the `SessionManagerPermissions` IAM role for Systems Manager access.

The launch template uses a `c7a.8xlarge` instance type and a 500 GB encrypted GP3 volume. Terraform looks up the latest matching Amazon-owned Windows Server 2025 AMI for each Region. At first boot, `userdata.ps` installs the AWS CLI and forensics tools, then restarts the instance.

## Prerequisites

- Terraform and AWS credentials with permissions to create the listed network, EC2, and IAM resources.
- An AWS account where the intended Regions and instance type are available.

The AWS provider is configured in `us-east-1` for region discovery. The root module then creates lab resources in every enabled Region returned by the `aws_regions` data source. Review the planned Regions and costs before applying: NAT gateways and interface endpoints can incur charges in each Region.

If the account already has an IAM role named `SessionManagerPermissions`, import it into Terraform state before applying this configuration.

## Use

Run Terraform from `infra/`:

```bash
cd infra
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```

To remove resources managed by this configuration, run `terraform destroy` from `infra/`.

Terraform state can contain sensitive information. Store it securely and do not commit it to the repository.

## Repository layout

- `infra/main.tf` configures the provider and regional module instances.
- `infra/iam.tf` creates the EC2 role and attaches the Systems Manager policy.
- `infra/modules/forensics_lab/main.tf` defines the regional infrastructure and AMI lookup.
- `infra/modules/forensics_lab/userdata.ps` initializes a workstation at first boot.

## License

This repository is licensed under the MIT License. See [LICENSE](LICENSE).

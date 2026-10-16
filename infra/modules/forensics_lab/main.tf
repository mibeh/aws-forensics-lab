# VPC
resource "aws_vpc" "ForensicsLab" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  region               = var.aws_region

  tags = {
    Name = "ForensicsLab"
  }
}

# Subnets
resource "aws_subnet" "ForensicsLabPrivateSubnet" {
  vpc_id            = aws_vpc.ForensicsLab.id
  cidr_block        = "10.0.1.0/24"
  region            = var.aws_region
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "ForensicsLabPrivateSubnet"
  }
}

resource "aws_subnet" "ForensicsLabPublicSubnet" {
  vpc_id            = aws_vpc.ForensicsLab.id
  cidr_block        = "10.0.2.0/24"
  region            = var.aws_region
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "ForensicsLabPublicSubnet"
  }
}

# NAT Gateway
resource "aws_eip" "ForensicsLabNATEIP" {
  region = var.aws_region
  tags = {
    Name = "ForensicsLabNATEIP"
  }
}
resource "aws_nat_gateway" "ForensicsLabNATGateway" {
  subnet_id         = aws_subnet.ForensicsLabPublicSubnet.id
  allocation_id     = aws_eip.ForensicsLabNATEIP.id
  connectivity_type = "public"
  depends_on        = [aws_internet_gateway.ForensicsLabIGW]
  region            = var.aws_region

  tags = {
    Name = "ForensicsLabNATGateway"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ForensicsLabIGW" {
  vpc_id = aws_vpc.ForensicsLab.id
  region = var.aws_region

  tags = {
    Name = "ForensicsLabIGW"
  }
}

# Route Tables
resource "aws_route_table" "ForensicsLabPrivateRouteTable" {
  vpc_id = aws_vpc.ForensicsLab.id
  region = var.aws_region
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ForensicsLabNATGateway.id
  }

  tags = {
    Name = "ForensicsLabPrivateRouteTable"
  }
}

resource "aws_route_table_association" "ForensicsLabPrivateSubnetAssociation" {
  subnet_id      = aws_subnet.ForensicsLabPrivateSubnet.id
  route_table_id = aws_route_table.ForensicsLabPrivateRouteTable.id
  region         = var.aws_region
}

resource "aws_route_table" "ForensicsLabPublicRouteTable" {
  vpc_id = aws_vpc.ForensicsLab.id
  region = var.aws_region
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ForensicsLabIGW.id
  }

  tags = {
    Name = "ForensicsLabPublicRouteTable"
  }
}

resource "aws_route_table_association" "ForensicsLabPublicSubnetAssociation" {
  subnet_id      = aws_subnet.ForensicsLabPublicSubnet.id
  route_table_id = aws_route_table.ForensicsLabPublicRouteTable.id
  region         = var.aws_region
}

# VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.ForensicsLab.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  region            = var.aws_region
  tags = {
    Name = "ForensicsLabS3Endpoint"
  }
}
resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.ForensicsLab.id
  subnet_ids          = [aws_subnet.ForensicsLabPublicSubnet.id]
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ForensicsLabVPCEndpointSG.id]
  region              = var.aws_region
  tags = {
    Name = "ForensicsLabEC2Endpoint"
  }
}
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.ForensicsLab.id
  subnet_ids          = [aws_subnet.ForensicsLabPublicSubnet.id]
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ForensicsLabVPCEndpointSG.id]
  region              = var.aws_region
  tags = {
    Name = "ForensicsLabLogsEndpoint"
  }
}
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.ForensicsLab.id
  subnet_ids          = [aws_subnet.ForensicsLabPublicSubnet.id]
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ForensicsLabVPCEndpointSG.id]
  region              = var.aws_region
  tags = {
    Name = "ForensicsLabEC2MessagesEndpoint"
  }
}
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.ForensicsLab.id
  subnet_ids          = [aws_subnet.ForensicsLabPublicSubnet.id]
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ForensicsLabVPCEndpointSG.id]
  region              = var.aws_region
  tags = {
    Name = "ForensicsLabSSMMessagesEndpoint"
  }
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.ForensicsLab.id
  subnet_ids          = [aws_subnet.ForensicsLabPublicSubnet.id]
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ForensicsLabVPCEndpointSG.id]
  region              = var.aws_region
  tags = {
    Name = "ForensicsLabSSMEndpoint"
  }
}
resource "aws_vpc_endpoint" "kms" {
  vpc_id              = aws_vpc.ForensicsLab.id
  subnet_ids          = [aws_subnet.ForensicsLabPublicSubnet.id]
  service_name        = "com.amazonaws.${var.aws_region}.kms"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.ForensicsLabVPCEndpointSG.id]
  region              = var.aws_region
  tags = {
    Name = "ForensicsLabKMSEndpoint"
  }
}

# Windows Workstation EC2 Launch Template
resource "aws_launch_template" "ForensicsLabWinWorkstation" {
  name_prefix            = "ForensicsLabWinServerWorkstation"
  image_id               = data.aws_ami.windows_server_2025.id
  instance_type          = "c7a.8xlarge"
  update_default_version = true
  region                 = var.aws_region

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 500
      encrypted             = true
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 250
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint          = "enabled"
    http_tokens            = "required"
    instance_metadata_tags = "enabled"
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.ForensicsLabWorkstationIAMProfile.arn
  }

  network_interfaces {
    associate_public_ip_address = false
    subnet_id                   = aws_subnet.ForensicsLabPrivateSubnet.id
    security_groups             = [aws_security_group.ForensicsLabWorkstationSG.id]
    delete_on_termination       = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Forensics Lab Workstation"
    }
  }

  user_data = filebase64("${path.module}/userdata.ps")

  description = "Launch template for forensics lab Windows Server Workstation"
  tags = {
    Name = "ForensicsLabWinServerWorkstationTemplate"
  }
}

# Data source to fetch the latest Windows Server 2025 AMI for the current region
data "aws_ami" "windows_server_2025" {
  most_recent = true
  owners      = ["amazon"]
  region      = var.aws_region

  filter {
    name   = "name"
    values = ["Windows_Server-2025-*English*Full*Base*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Instance IAM Profile
resource "aws_iam_instance_profile" "ForensicsLabWorkstationIAMProfile" {
  name = "ForensicsLabWorkstationIAMProfile-${var.aws_region}"
  role = "SessionManagerPermissions"
}

# Workstation Security Group
resource "aws_security_group" "ForensicsLabWorkstationSG" {
  name        = "Forensics Lab Workstation SG"
  description = "Security group for Forensics Lab Workstations"
  vpc_id      = aws_vpc.ForensicsLab.id
  region      = var.aws_region
  tags = {
    Name = "Forensics Lab Workstation SG"
  }
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_egress" {
  security_group_id = aws_security_group.ForensicsLabWorkstationSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
  description       = "Allow all outbound traffic"
  region            = var.aws_region
}
resource "aws_vpc_security_group_egress_rule" "allow_DNS_UDP_traffic_egress" {
  security_group_id = aws_security_group.ForensicsLabWorkstationSG.id
  cidr_ipv4         = "10.0.0.2/32"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  description       = "Allow DNS UDP traffic"
  region            = var.aws_region
}
resource "aws_vpc_security_group_egress_rule" "allow_DNS_TCP_traffic_egress" {
  security_group_id = aws_security_group.ForensicsLabWorkstationSG.id
  cidr_ipv4         = "10.0.0.2/32"
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  description       = "Allow DNS TCP traffic"
  region            = var.aws_region
}

# VPC Endpoint Security Group
resource "aws_security_group" "ForensicsLabVPCEndpointSG" {
  name        = "Forensics Lab VPC Endpoint SG"
  description = "Security group for VPC endpoints in Forensics Lab"
  vpc_id      = aws_vpc.ForensicsLab.id
  region      = var.aws_region
  tags = {
    Name = "Forensics Lab VPC Endpoint SG"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_traffic_from_workstations" {
  security_group_id            = aws_security_group.ForensicsLabVPCEndpointSG.id
  referenced_security_group_id = aws_security_group.ForensicsLabWorkstationSG.id
  ip_protocol                  = "-1"
  description                  = "Allow all inbound traffic from the Forensics Lab Workstations"
  region                       = var.aws_region
}
resource "aws_vpc_security_group_egress_rule" "allow_outbound_traffic" {
  security_group_id = aws_security_group.ForensicsLabVPCEndpointSG.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
  region            = var.aws_region
}

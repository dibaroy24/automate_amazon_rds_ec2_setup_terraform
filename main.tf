provider "aws" {
  region = var.location
  # access_key = var.access_key
  # secret_key = var.secret_key
}

# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

# Create Public Subnet
resource "aws_subnet" "vpc_public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.location}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-pub-subnet"
  }
}

# Create Private Subnet
resource "aws_subnet" "vpc_private_subnet_a" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.location}a"
  tags = {
    Name = "${var.prefix}-pvt-subnet-1"
  }
}

resource "aws_subnet" "vpc_private_subnet_b" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "${var.location}b"
  tags = {
    Name = "${var.prefix}-pvt-subnet-2"
  }
}

# Create Public Route Table
resource "aws_route_table" "vpc_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "${var.prefix}-public-rt"
  }
}

# Create Private Route Table
resource "aws_route_table" "vpc_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.my_igw] # Ensure IGW exists before EIP
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.vpc_public_subnet.id
  tags = {
    Name = "${var.prefix}-nat-gw"
  }
}

# Associate the EIP with an EC2 Instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.nat_eip.id
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.vpc_public_subnet.id
  route_table_id = aws_route_table.vpc_public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.vpc_private_subnet_a.id
  route_table_id = aws_route_table.vpc_private_route_table.id
}

# Create a DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.vpc_private_subnet_a.id, aws_subnet.vpc_private_subnet_b.id]
  tags = {
    Name = "${var.prefix}-db-subnet-group"
  }
}

# Create Security Groups
resource "aws_security_group" "rds_sg" {
  name        = "rds-postgres-sg"
  description = "Allow PostgreSQL access from EC2"
  vpc_id = aws_vpc.my_vpc.id
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Update to only allow EC2 CIDR for security
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-allow-postgres"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH"
  vpc_id = aws_vpc.my_vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Limit to your IP in production
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-allow-ssh"
  }
}

# Create RDS
resource "aws_db_instance" "postgres" {
  identifier        = "${var.prefix}-postgres-db"
  engine            = "postgres"
  engine_version    = "14"
  instance_class    = "db.t3.micro"
  username          = var.admin_user
  password          = var.admin_password
  allocated_storage = 20
  db_name           = var.new_db
  multi_az          = false
  publicly_accessible = true
  skip_final_snapshot = true

  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.default.name

  tags = {
    Name = "${var.prefix}-rds"
  }
}

# Create EC2
resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ec2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2_key.key_name
  subnet_id     = aws_subnet.vpc_public_subnet.id
  # security_groups = [aws_security_group.ec2_sg.name]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = file("scripts/init.sh")

  tags = {
    Name = "${var.prefix}-client-ec2"
  }

  depends_on = [aws_db_instance.postgres]
}


# Create VPC example 100.64.0.0/16
resource "aws_vpc" "vpc-example" {
  cidr_block           = "100.64.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "vpc-example" }
}

# Create the internet gateway
resource "aws_internet_gateway" "igw-example" {
  vpc_id = aws_vpc.vpc-example.id
  tags   = { Name = "igw-example" }
}

# Create the public subnet
resource "aws_subnet" "public-tf-SN" {
  vpc_id                  = aws_vpc.vpc-example.id
  cidr_block              = "100.64.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = { Name = "public-tf-SN" }
}

# Create the private subnet
resource "aws_subnet" "private-tf-SN" {
  vpc_id            = aws_vpc.vpc-example.id
  cidr_block        = "100.64.2.0/24"
  availability_zone = "us-east-1b"
  tags              = { Name = "private-tf-SN" }
}

# Create the public route table
resource "aws_route_table" "public-tf-RT" {
  vpc_id = aws_vpc.vpc-example.id
  tags   = { Name = "public-tf-RT" }

}

# Add a default route to internet to the Route table
resource "aws_route" "public-tf-route" {
  route_table_id         = aws_route_table.public-tf-RT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw-example.id
}

# Associate the public subnet to the public route table
resource "aws_route_table_association" "public-SN-to_public_RT" {
  route_table_id = aws_route_table.public-tf-RT.id
  subnet_id      = aws_subnet.public-tf-SN.id
}

# Create the Security Group
resource "aws_security_group" "sg-tf" {
  name        = "allow SSH and HTTP"
  description = "allow SSH and HTTP"
  vpc_id      = aws_vpc.vpc-example.id
  tags        = { Name = "sg-tf" }
}

# Add rule to security group "sg-tf" to allow ingress (inbound) ssh traffic
resource "aws_vpc_security_group_ingress_rule" "allow-ssh" {
  security_group_id = aws_security_group.sg-tf.id
  cidr_ipv4         = "0.0.0.0/0"
  to_port           = 22
  from_port         = 22
  ip_protocol       = "tcp"
}
# Add rule to security group "sg-tf" to allow ingress (inbound) http traffic
resource "aws_vpc_security_group_ingress_rule" "allow-web" {
  security_group_id = aws_security_group.sg-tf.id
  cidr_ipv4         = "0.0.0.0/0"
  to_port           = 80
  from_port         = 80
  ip_protocol       = "tcp"
}

# Allow all egress (outbound) traffic
resource "aws_vpc_security_group_egress_rule" "all-outbound" {
  security_group_id = aws_security_group.sg-tf.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Create ec2 instance running public webserver
resource "aws_instance" "ec2-terraformed" {
  ami             = data.aws_ami.latest_ami.id
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public-tf-SN.id
  security_groups = [aws_security_group.sg-tf.id]
  key_name        = "key-tuesday"
  tags            = { Name = "ec2-terraformed" }
  user_data       = file("userdata.sh")

}
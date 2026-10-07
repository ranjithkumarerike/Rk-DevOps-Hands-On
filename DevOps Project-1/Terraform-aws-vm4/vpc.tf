provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "DevOps-Network" }
}

resource "aws_subnet" "devops_subnet" {
  vpc_id            = aws_vpc.devops_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = { Name = "DevOps-Subnet" }
}

resource "aws_internet_gateway" "devops_igw" {
  vpc_id = aws_vpc.devops_vpc.id
}

resource "aws_route_table" "devops_rt" {
  vpc_id = aws_vpc.devops_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops_igw.id
  }
}

resource "aws_route_table_association" "devops_rta" {
  subnet_id      = aws_subnet.devops_subnet.id
  route_table_id = aws_route_table.devops_rt.id
}

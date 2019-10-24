#Network part of the template
#MAde by TOR


#Create VPC
resource "aws_vpc" "torlo-tform-vpc" {
  cidr_block           = "${var.torlo-vpc-cidr}"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "torlo-tform-vpc"
  }
}

#Create IGW
resource "aws_internet_gateway" "torlo-terraform-igw" {
  vpc_id = "${aws_vpc.torlo-tform-vpc.id}"
  tags = {
    Name = "torlo-tform-igw"
  }
}

#Create Elastic IP for NAT Gateway
resource "aws_eip" "torlo-eip-nat" {
  count = "${length(var.subnet_cidrs_private)}"
  vpc   = true
  tags = {
    Name = "torlo-tform-ip-${count.index}"
  }
}

#Create NAT Gateway
resource "aws_nat_gateway" "terraform-tform-nat" {
  count         = "${length(var.subnet_cidrs_private)}"
  allocation_id = "${aws_eip.torlo-eip-nat[count.index].id}"
  subnet_id     = "${element(aws_subnet.torlo-tform-pub.*.id, count.index)}"
  tags = {
    Name = "torlo-tform-NAT-${count.index}"
  }
}

#Create Network subnets
resource "aws_subnet" "torlo-tform-pub" {
  count = "${length(var.subnet_cidrs_public)}"

  vpc_id                  = "${aws_vpc.torlo-tform-vpc.id}"
  cidr_block              = "${var.subnet_cidrs_public[count.index]}"
  availability_zone       = "${var.availability_zones[count.index]}"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "torlo-tform-subnet-public-${count.index}"
  }

}

resource "aws_subnet" "torlo-tform-pri" {
  count = "${length(var.subnet_cidrs_private)}"

  vpc_id            = "${aws_vpc.torlo-tform-vpc.id}"
  cidr_block        = "${var.subnet_cidrs_private[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"
  tags = {
    Name = "torlo-tform-subnet-private-${count.index}"
  }
}

#Create and configure route for pulic subnets
resource "aws_route_table" "torlo-public" {
  vpc_id = "${aws_vpc.torlo-tform-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.torlo-terraform-igw.id}"
  }
  tags = {
    Name = "torlo-tform-rt-public"
  }
}

resource "aws_route_table_association" "torlo-public-rt" {
  count = "${length(var.subnet_cidrs_public)}"

  subnet_id      = "${element(aws_subnet.torlo-tform-pub.*.id, count.index)}"
  route_table_id = "${aws_route_table.torlo-public.id}"
}

#Create and configure route table for private subnets
resource "aws_route_table" "torlo-private" {
  count  = "${length(var.subnet_cidrs_private)}"
  vpc_id = "${aws_vpc.torlo-tform-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_nat_gateway.terraform-tform-nat.*.id, count.index)}"
  }
  tags = {
    Name = "torlo-tform-rt-private-${count.index}"
  }
}

resource "aws_route_table_association" "torlo-private-rt" {
  count = "${length(var.subnet_cidrs_private)}"

  subnet_id      = "${element(aws_subnet.torlo-tform-pri.*.id, count.index)}"
  route_table_id = "${aws_route_table.torlo-private[count.index].id}"
}

#Create security groups
resource "aws_security_group" "torlo-tform-sg-priv-ssh" {
  name        = "torlo-tform-sg-priv-ssh"
  vpc_id      = "${aws_vpc.torlo-tform-vpc.id}"
  description = "tform sg ssh pri"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "torlo-tform-sg-pri-ssh"
  }
}

resource "aws_security_group" "torlo-tform-sg-pub-ssh" {
  name        = "torlo-tform-sg-pub-ssh"
  vpc_id      = "${aws_vpc.torlo-tform-vpc.id}"
  description = "tform sg ssh pri"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["185.112.172.83/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "torlo-tform-sg-pri-ssh"
  }
}

resource "aws_security_group" "torlo-tform-sg-pri-logstash" {
  name        = "torlo-tform-sg-pri-ssh"
  vpc_id      = "${aws_vpc.torlo-tform-vpc.id}"
  description = "tform sg logstash pri"

  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "torlo-tform-sg-pri-logstash"
  }
}

resource "aws_security_group" "torlo-tform-sg-pri-elastic" {
  name        = "torlo-tform-sg-pri-elastic"
  vpc_id      = "${aws_vpc.torlo-tform-vpc.id}"
  description = "tform sg elastic pri"

  ingress {
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "torlo-tform-sg-pri-elastic"
  }
}

resource "aws_security_group" "torlo-tform-sg-pub-http" {
  name        = "torlo-tform-sg-pub-http"
  vpc_id      = "${aws_vpc.torlo-tform-vpc.id}"
  description = "tform sg public http"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "torlo-tform-sg-pub-http"
  }
}

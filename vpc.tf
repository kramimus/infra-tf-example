resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "subneta" {
  vpc_id     = "${aws_vpc.main.id}"
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "subnetb" {
  vpc_id     = "${aws_vpc.main.id}"
  availability_zone = "us-east-1b"
  cidr_block = "10.0.0.0/24"
}


resource "aws_internet_gateway" "igw" {
  vpc_id     = "${aws_vpc.main.id}"
}

resource "aws_route_table" "rtl" {
  vpc_id = "${aws_vpc.main.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_route_table_association" "suba-rt" {
  route_table_id = "${aws_route_table.rtl.id}"
  subnet_id = "${aws_subnet.subneta.id}"
}

resource "aws_route_table_association" "subb-rt" {
  route_table_id = "${aws_route_table.rtl.id}"
  subnet_id = "${aws_subnet.subnetb.id}"
}


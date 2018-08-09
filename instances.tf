provider "aws" {
  region     = "us-east-1"
}

data "aws_availability_zones" "all" {}

data "aws_ami" "portal" {
  most_recent = true
  owners = ["self"]

  filter {
    name   = "name"
    values = ["web-portal-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "hardware" {
  most_recent = true
  owners = ["self"]
  
  filter { 
    name   = "name"
    values = ["web-hardware-*"]
  }
  
  filter { 
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_route53_zone" "private_zone" {
  name = "example.com"
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route53_record" "hardware_hostname" {
  zone_id = "${aws_route53_zone.private_zone.zone_id}"
  name = "hardware.${aws_route53_zone.private_zone.name}"
  type = "A"
  ttl = 60
  records = ["${aws_instance.hardware.private_ip}"]
}

### Creating EC2 instance
resource "aws_instance" "portal" {
  ami               = "${data.aws_ami.portal.id}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.public_instance.id}"]
  source_dest_check = false
  instance_type = "t2.nano"
  subnet_id = "${aws_subnet.subneta.id}"

tags {
    Name = "portal"
  }
}

### Creating EC2 instance
resource "aws_instance" "hardware" {
  ami               = "${data.aws_ami.hardware.id}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.private_instance.id}"]
  source_dest_check = false
  instance_type = "t2.nano"

  subnet_id = "${aws_subnet.subnetb.id}"
tags {
    Name = "hardware"
  }
}

### Creating Security Group for EC2
resource "aws_security_group" "public_instance" {
  name = "public-instance"
  vpc_id     = "${aws_vpc.main.id}"
  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["10.0.0.0/16"]
  }
}

### Creating Security Group for EC2
resource "aws_security_group" "private_instance" {
  name = "private-instance"
  vpc_id     = "${aws_vpc.main.id}"
  ingress {
    from_port = 5001
    to_port = 5001
    protocol = "tcp"
    security_groups = ["${aws_security_group.public_instance.id}"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["10.0.0.0/16"]
  }

}



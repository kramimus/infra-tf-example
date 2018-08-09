resource "aws_launch_configuration" "example" {
  image_id               = "${data.aws_ami.portal.id}"
  instance_type          = "t2.nano"
  security_groups        = ["${aws_security_group.public_instance.id}"]
  key_name               = "${var.key_name}"
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  min_size = 2
  max_size = 10
  target_group_arns = ["${aws_lb_target_group.public-target.arn}"]
  vpc_zone_identifier = ["${aws_subnet.subneta.id}", "${aws_subnet.subnetb.id}"]
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "public-lb" {
  name = "public-lb"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "public-asg" {
  name = "public-asg"
  security_groups = ["${aws_security_group.public-lb.id}"]
  internal = false
  subnets = ["${aws_subnet.subneta.id}", "${aws_subnet.subnetb.id}"]
}

resource "aws_lb_target_group" "public-target" {
  name = "public-target"
  port = 5000
  protocol = "HTTP"
  vpc_id = "${aws_vpc.main.id}"
  health_check {
    path = "/"
    timeout = 10
    interval = 60
  }
}

resource "aws_lb_target_group_attachment" "public-attach" {
  target_group_arn = "${aws_lb_target_group.public-target.arn}"
  target_id = "${aws_instance.portal.id}"
}

resource "aws_lb_listener" "public-frontend" {
  load_balancer_arn = "${aws_lb.public-asg.arn}"
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = "${aws_lb_target_group.public-target.arn}"
    type = "forward"
  }
}

output "lb-hostname" {
  value = "${aws_lb.public-asg.dns_name}"
}

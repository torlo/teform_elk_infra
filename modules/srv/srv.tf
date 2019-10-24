

module "vpc" {
  source = "../network"
}

resource "aws_instance" "torlo-tform-ansible" {
  count                       = 1
  ami                         = "ami-007857f6976b8460d"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.aws_pub_subnet, count.index)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${module.vpc.sg_pub-ssh}", "${module.vpc.sg_priv-ssh}"]
  key_name                    = "torlov.test"

  tags = {
    Name = "torlo-tform-ansible-master"
  }
}

resource "aws_instance" "torlo-tform-kibana" {
  count                       = 1
  ami                         = "ami-0b432b9079015a8c0"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.aws_pub_subnet, count.index)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${module.vpc.sg_pub-ssh}", "${module.vpc.sg_priv-ssh}", "${module.vpc.sg_pub-http}"]
  key_name                    = "torlov.test"

  tags = {
    Name = "torlo-tform-kibana"
  }
}
resource "aws_instance" "torlo-tform-elastic1" {
  count                       = 1
  ami                         = "ami-0b432b9079015a8c0"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.aws_pub_subnet, count.index)}"
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.vpc.sg_priv-elastic}", "${module.vpc.sg_priv-ssh}"]
  key_name                    = "torlov.test"

  tags = {
    Name = "torlo-tform-elastic1"
  }
}
resource "aws_instance" "torlo-tform-elastic2" {
  count                       = 1
  ami                         = "ami-0b432b9079015a8c0"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.aws_pub_subnet, count.index)}"
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.vpc.sg_priv-elastic}", "${module.vpc.sg_priv-ssh}"]
  key_name                    = "torlov.test"

  tags = {
    Name = "torlo-tform-elastic2"
  }
}
resource "aws_instance" "torlo-tform-elastic3" {
  count                       = 1
  ami                         = "ami-0b432b9079015a8c0"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.aws_pub_subnet, count.index)}"
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.vpc.sg_priv-elastic}", "${module.vpc.sg_priv-ssh}"]
  key_name                    = "torlov.test"

  tags = {
    Name = "torlo-tform-elastic3"
  }
}
resource "aws_instance" "torlo-tform-logstash" {
  count                       = 1
  ami                         = "ami-0b432b9079015a8c0"
  instance_type               = "t2.small"
  subnet_id                   = "${element(module.vpc.aws_pub_subnet, count.index)}"
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.vpc.sg_pri-logstash}", "${module.vpc.sg_priv-ssh}"]
  key_name                    = "torlov.test"

  tags = {
    Name = "torlo-tform-logstash"
  }
}

#Terraform template for ELK cluster infrastructure
#Main file

provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "./network"
}

resource "aws_instance" "torlo-tform-ansible" {
  count                       = 1
  ami                         = "ami-088f410fb8317eb48"
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

data "template_file" "hosts" {
  count    = 1
  template = "${file("./hosts.tpl")}"
  vars = {
    elastic-ip-1 = "${aws_instance.torlo-tform-elastic1[count.index].private_ip}"
    elastic-ip-2 = "${aws_instance.torlo-tform-elastic2[count.index].private_ip}"
    elastic-ip-3 = "${aws_instance.torlo-tform-elastic3[count.index].private_ip}"
    logstash-ip  = "${aws_instance.torlo-tform-logstash[count.index].private_ip}"
    kibana-ip    = "${aws_instance.torlo-tform-kibana[count.index].private_ip}"
  }
}

resource "null_resource" replace_file_hosts {
  depends_on = ["template_file.hosts"]
  count      = 1
  #  depends_on = ["aws_instance.torlo-tform-ansible"]
  connection {
    host        = "${aws_instance.torlo-tform-ansible[count.index].public_ip}"
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file("./network/.ssh/id_rsa")}"
    agent       = "false"
  }

  provisioner "remote-exec" {
    inline = ["sudo rm -rf /etc/hosts"]
  }
  provisioner "file" {
    source      = "hosts.tpl"
    destination = "/home/ec2-user/hosts"
  }
  provisioner "remote-exec" {
    inline = ["sudo cp /home/ec2-user /etc/hosts"]
  }
  provisioner "remote-exec" {
    inline = ["sudo chown root:root /etc/hosts"]
  }
}

#Terraform template for ELK cluster infrastructure
#Main file

provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "./modules/network"
}

resource "aws_instance" "torlo-tform-ansible" {
  depends_on                  = ["module.vpc"]
  count                       = 1
  ami                         = "ami-0976f50297d2fcfd9"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.aws_pub_subnet, count.index)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${module.vpc.sg_pub-ssh}", "${module.vpc.sg_priv-ssh}"]
  key_name                    = "torlov.test"
  user_data                   = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname ansible
    $EL1IP=${aws_instance.torlo-tform-elastic1[count.index].private_ip}
    $EL1IP=${aws_instance.torlo-tform-elastic2[count.index].private_ip}
    $EL1IP=${aws_instance.torlo-tform-elastic3[count.index].private_ip}
  EOF
  tags = {
    Name = "torlo-tform-ansible-master"
  }
}

resource "aws_instance" "torlo-tform-kibana" {
  depends_on                  = ["module.vpc", "aws_instance.torlo-tform-ansible"]
  count                       = 1
  ami                         = "ami-0b432b9079015a8c0"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.aws_pub_subnet, count.index)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${module.vpc.sg_pub-ssh}", "${module.vpc.sg_priv-ssh}", "${module.vpc.sg_pub-http}"]
  key_name                    = "torlov.test"
  user_data                   = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname kibana
  EOF
  tags = {
    Name = "torlo-tform-kibana"
  }
}
resource "aws_instance" "torlo-tform-elastic1" {
  depends_on                  = ["module.vpc", "aws_instance.torlo-tform-ansible"]
  count                       = 1
  ami                         = "ami-0b432b9079015a8c0"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.aws_pri_subnet, count.index)}"
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.vpc.sg_priv-elastic}", "${module.vpc.sg_priv-ssh}"]
  key_name                    = "torlov.test"
  user_data                   = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname elastic1
  EOF

  tags = {
    Name = "torlo-tform-elastic1"
  }
}
resource "aws_instance" "torlo-tform-elastic2" {
  depends_on                  = ["module.vpc", "aws_instance.torlo-tform-ansible"]
  count                       = 1
  ami                         = "ami-0b432b9079015a8c0"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.aws_pri_subnet, count.index)}"
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.vpc.sg_priv-elastic}", "${module.vpc.sg_priv-ssh}"]
  key_name                    = "torlov.test"
  user_data                   = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname elastic2
  EOF
  tags = {
    Name = "torlo-tform-elastic2"
  }
}
resource "aws_instance" "torlo-tform-elastic3" {
  depends_on                  = ["module.vpc", "aws_instance.torlo-tform-ansible"]
  count                       = 1
  ami                         = "ami-0b432b9079015a8c0"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.aws_pri_subnet, count.index)}"
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.vpc.sg_priv-elastic}", "${module.vpc.sg_priv-ssh}"]
  key_name                    = "torlov.test"
  user_data                   = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname elastic3
  EOF
  tags = {
    Name = "torlo-tform-elastic3"
  }
}
resource "aws_instance" "torlo-tform-logstash" {
  depends_on                  = ["module.vpc", "aws_instance.torlo-tform-ansible"]
  count                       = 1
  ami                         = "ami-0b432b9079015a8c0"
  instance_type               = "t2.small"
  subnet_id                   = "${element(module.vpc.aws_pri_subnet, count.index)}"
  associate_public_ip_address = false
  vpc_security_group_ids      = ["${module.vpc.sg_pri-logstash}", "${module.vpc.sg_priv-ssh}"]
  key_name                    = "torlov.test"
  user_data                   = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname logstash
  EOF
  tags = {
    Name = "torlo-tform-logstash"
  }
}

output "es1_pri-ip" {
  value = "${aws_instance.torlo-tform-elastic1.*.private_ip}"
}
output "es2_pri-ip" {
  value = "${aws_instance.torlo-tform-elastic2.*.private_ip}"
}
output "es3_pri-ip" {
  value = "${aws_instance.torlo-tform-elastic3.*.private_ip}"
}
output "kibana_pri-ip" {
  value = "${aws_instance.torlo-tform-kibana.*.private_ip}"
}
output "logstash_pri-ip" {
  value = "${aws_instance.torlo-tform-logstash.*.private_ip}"
}
output "ansible-pub-ip" {
  value = "${aws_instance.torlo-tform-ansible.*.public_ip}"
}

resource "null_resource" "replace_file_hosts" {
  count      = 1
  depends_on = ["aws_instance.torlo-tform-logstash"]
  connection {
    host        = "${aws_instance.torlo-tform-ansible[count.index].public_ip}"
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file("./modules/network/.ssh/id_rsa")}"
    agent       = "false"
  }
  provisioner "remote-exec" {
    inline = ["sudo echo '127.0.0.1   localhost' > /tmp/hosts"]
  }
  provisioner "remote-exec" {
    inline = ["sudo echo '${aws_instance.torlo-tform-elastic1[count.index].private_ip}   elastic1.local' >> /tmp/hosts"]
  }
  provisioner "remote-exec" {
    inline = ["sudo echo '${aws_instance.torlo-tform-elastic2[count.index].private_ip}   elastic2.local' >> /tmp/hosts"]
  }
  provisioner "remote-exec" {
    inline = ["sudo echo '${aws_instance.torlo-tform-elastic3[count.index].private_ip}   elastic3.local' >> /tmp/hosts"]
  }
  provisioner "remote-exec" {
    inline = ["sudo echo '${aws_instance.torlo-tform-kibana[count.index].private_ip}   kibana.local' >> /tmp/hosts"]
  }
  provisioner "remote-exec" {
    inline = ["sudo echo '${aws_instance.torlo-tform-logstash[count.index].private_ip}   logstash.local' >> /tmp/hosts"]
  }
  provisioner "remote-exec" {
    inline = ["sudo cp -f /tmp/hosts /etc/hosts"]
  }
  provisioner "remote-exec" {
    inline = ["sudo chown root:root /etc/hosts"]
  }
  provisioner "remote-exec" {
    inline = ["sudo cp /etc/hosts /etc/ansible/inventory/vars/elk_cluster/hosts.j2"]
  }
}

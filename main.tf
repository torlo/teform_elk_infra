#Terraform template for ELK cluster infrastructure
#Main file

provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source = "./modules/network"
}
module "srv" {
  source = "./modules/srv"
}



resource "null_resource" "replace_file_hosts" {
  #  depends_on = ["template_file.hosts"]
  count = 1
  #  depends_on = ["aws_instance.torlo-tform-ansible"]
  connection {
    host        = "${module.srv.ansible-pub-ip}"
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${file("./modules/network/.ssh/id_rsa")}"
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
    inline = ["sudo cp /home/ec2-user/hosts /etc/hosts"]
  }
  provisioner "remote-exec" {
    inline = ["sudo chown root:root /etc/hosts"]
  }
}

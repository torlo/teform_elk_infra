output "aws_vpc" {
  value       = "aws_vpc.torlo-tform-vpc.id"
  description = "VPC"
}

output "aws_pub_subnet" {
  value       = "${aws_subnet.torlo-tform-pub.*.id}"
  description = "list of public subnets."
}

output "aws_pri_subnet" {
  value       = "${aws_subnet.torlo-tform-pri.*.id}"
  description = "list of private subnets"
}

output "sg_priv-ssh" {
  value = "${aws_security_group.torlo-tform-sg-priv-ssh.id}"
}

output "sg_pub-ssh" {
  value = "${aws_security_group.torlo-tform-sg-pub-ssh.id}"
}

output "sg_pri-logstash" {
  value = "${aws_security_group.torlo-tform-sg-pri-logstash.id}"
}

output "sg_priv-elastic" {
  value = "${aws_security_group.torlo-tform-sg-pri-elastic.id}"
}

output "sg_pub-http" {
  value = "${aws_security_group.torlo-tform-sg-pub-http.id}"
}

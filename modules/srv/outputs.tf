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

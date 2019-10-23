#data "template_file" "hosts" {
#  template = "${file("./hosts.tpl")}"
#  vars = {
#    elastic-ip-2 = "$aws_instance.torlo-tform-elastic2.private_ip.id"
#    elastic-ip-3 = "$aws_instance.torlo-tform-elastic3.private_ip.id"
#    logstash-ip  = "$aws_instance.torlo-tform-logstash.private_ip.id"
#    kibana-ip    = "$aws_instance.torlo-tform-kibana.private_ip.id"
#  }
#}

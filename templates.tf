#data "template_file" "hosts" {
#  template = "${file("${path.module}/hosts.tpl")}"
#  vars = {
#    elastic-ip-1 = "${module.srv.es1_pri-ip}"
#    elastic-ip-2 = "${module.srv.es2_pri-ip}"
#    elastic-ip-3 = "${module.srv.es3_pri-ip}"
#    logstash-ip  = "${module.srv.logstash_pri-ip}"
#    kibana-ip    = "${module.srv.kibana_pri-ip}"
#  }
#}

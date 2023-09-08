resource "aws_instance" "instance" {
  ami                       = data.aws_ami.ami.id
  instance_type             = var.instance_type
  #vpc_security_group_ids   = [aws_security_group.prometheus1.id]
#  security_groups          = [aws_security_group.prometheus1.name]
  vpc_security_group_ids    = var.security_groups
  tags = {
    Name = var.name
    Monitor = var.value
  }

}
resource "aws_route53_record" "record" {

  zone_id = var.zone_id
  name    = "${var.name}-dev.tirupathib74.online"
  type    = "A"
  ttl     = 30
  records = [aws_instance.instance.private_ip]

}
#resource "aws_security_group" "prometheus1" {
#  name        = "prometheus1"
#  description = "prometheus_all"
#  vpc_id      = "vpc-095dcad0c8ac8c419"
#
#  ingress {
#    description      = "All traffic"
#    from_port        = 0
#    to_port          = 0
#    protocol         = "-1"
#    cidr_blocks      = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = ["::/0"]
#  }
#  ingress {
#    description      = "node_exporter"
#    from_port        = 9110
#    to_port          = 9110
#    protocol         = "tcp"
#    cidr_blocks      = var.monitoring_ingress_cidr
#
#  }
#
#  egress {
#    from_port        = 0
#    to_port          = 0
#    protocol         = "-1"
#    cidr_blocks      = ["0.0.0.0/0"]
#    ipv6_cidr_blocks = ["::/0"]
#  }
#
#  tags = {
#    Name = "prometheus1"
#  }
#}

resource "aws_security_group_rule" "nginx_exporter" {
  count             = var.name == "frontend" ? 1 : 0
  type              = "ingress"
  from_port         = 9113
  to_port           = 9113
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-06f905eeb15c22808"
}
resource "null_resource" "ansible" {
  depends_on = [
    aws_route53_record.record
  ]
  provisioner "local-exec" {
    command = <<EOF
cd /home/centos/roboshop-ansible-roles-monitoring_tools
git pull
sleep 30
ansible-playbook -i ${var.name}-dev.tirupathib74.online, main.yml -e ansible_user=centos -e ansible_password=DevOps321 -e component=${var.name}
EOF

  }
}
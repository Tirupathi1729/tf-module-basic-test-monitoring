resource "aws_instance" "instance" {
  ami                       = data.aws_ami.ami.id
  instance_type             = var.instance_type
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
resource "aws_security_group_rule" "nginx_exporter" {
  count             = var.name == "frontend" ? 1 : 0
  type              = "ingress"
  from_port         = 9113
  to_port           = 9113
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "sg-09f2ca421f162b6b5"
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
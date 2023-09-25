
resource "aws_lb" "k8_masters_lb" {
  name               = "test-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [var.cynapse_kubeadm_subnets]
  tags = {
    Name = "LB k8s master"
  }

}

# target_type instance not working well when we bound this LB as a control-plane-endpoint. hence had to use IP target_type
#https://stackoverflow.com/questions/56768956/how-to-use-kubeadm-init-configuration-parameter-controlplaneendpoint/70799078#70799078

resource "aws_lb_target_group" "k8_masters_api" {
  name        = "k8-masters-api"
  port        = 6443b
  protocol    = "TCP"
  vpc_id      = aws_vpc.kubeadm_cynapse_vpc.id
  target_type = "ip"

  health_check {
    port                = 6443
    protocol            = "TCP"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "k8_masters_lb_listener" {
  load_balancer_arn = aws_lb.k8_masters_lb.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.k8_masters_api.id
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "k8_masters_attachment" {
  target_group_arn = aws_lb_target_group.k8_masters_api.arn
  target_id        = aws_instance.kubeadm_cynapse_control_plane.private_ip
}

resource "aws_lb_target_group_attachment" "k8_worker01_attachment" {
  count            = length(aws_instance.kubeadm_cynapse_worker_nodes.*.id)
  target_group_arn = aws_lb_target_group.k8_masters_api.arn
  target_id        = aws_instance.kubeadm_cynapse_worker_nodes.*.private_ip[count.index]
}
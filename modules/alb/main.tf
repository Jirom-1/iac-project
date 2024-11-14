resource "aws_lb" "application-load-balancer" {
  name               = "${var.project-name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = var.subnets
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "http_rules" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http.id
}

resource "aws_security_group_rule" "egress-rule" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http.id
}

resource "aws_lb_listener" "http-listner" {
  load_balancer_arn = aws_lb.application-load-balancer.arn
  port              = var.alb_port
  protocol          = "HTTP"


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loabalancer-tg.arn
  }
}

resource "aws_lb_target_group" "loabalancer-tg" {
  name     = "${var.project-name}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    interval            = 60
    path                = "/app"
    timeout             = 30
    matcher             = "200"
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
}



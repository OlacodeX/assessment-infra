resource "aws_lb_target_group" "backend" {

  name = "backend-target-group"

  port = 8080

  protocol = "HTTP"

  vpc_id = var.vpc_id

  health_check {

    enabled             = true
    path                = "/ping"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}
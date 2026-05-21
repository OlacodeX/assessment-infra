resource "aws_autoscaling_group" "backend" {

  desired_capacity = 2

  max_size = 4

  min_size = 2

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    aws_lb_target_group.backend.arn
  ]

  launch_template {

    id = aws_launch_template.backend.id

    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 900

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
      instance_warmup        = 300
    }
  }
}

resource "aws_autoscaling_policy" "scale_out" {

  name = "scale-out"

  scaling_adjustment = 1

  adjustment_type = "ChangeInCapacity"

  autoscaling_group_name = aws_autoscaling_group.backend.name
}

resource "aws_autoscaling_policy" "scale_in" {

  name = "scale-in"

  scaling_adjustment = -1

  adjustment_type = "ChangeInCapacity"

  autoscaling_group_name = aws_autoscaling_group.backend.name
}
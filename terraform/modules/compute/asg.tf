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

  health_check_type = "ELB"
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
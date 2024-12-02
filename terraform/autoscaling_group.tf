resource "aws_autoscaling_group" "web_app_asg" {
  launch_template {
    id      = aws_launch_template.csye6225_asg.id
    version = "$Latest"
  }
  name                    = "csye6225_asg"
  min_size                = var.min_size
  max_size                = var.max_size
  desired_capacity        = var.desired_capacity
  default_cooldown        = var.cooldown
  default_instance_warmup = 300
  vpc_zone_identifier     = [for subnet in aws_subnet.public : subnet.id] # Public subnets

  tag {
    key                 = "Name"
    value               = "web_app_instance"
    propagate_at_launch = true
  }

  # Associate the target group with the Auto Scaling Group
  target_group_arns = [aws_lb_target_group.web_app_target_group.arn]

  health_check_type         = "EC2"
  health_check_grace_period = 300

}

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = "scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.cooldown
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
}

# CloudWatch Alarm for Scale Up
resource "aws_cloudwatch_metric_alarm" "cpu_usage_high" {
  alarm_name          = "cpu_usage_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.scale_up_evaluation_periods
  period              = var.scale_up_period
  threshold           = var.scale_up_threshold
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"


  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }

  alarm_description = "Alarm when CPU usage exceeds ${var.scale_up_threshold}%"

  alarm_actions             = [aws_autoscaling_policy.scale_up_policy.arn] # Action to scale up
  insufficient_data_actions = []
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = "scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.cooldown
  autoscaling_group_name = aws_autoscaling_group.web_app_asg.name
}

# CloudWatch Alarm for Scale Down
resource "aws_cloudwatch_metric_alarm" "cpu_usage_low" {
  alarm_name          = "cpu_usage_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.scale_down_evaluation_periods
  period              = var.scale_down_period
  threshold           = var.scale_down_threshold
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"


  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }

  alarm_description = "Alarm when CPU usage drops below ${var.scale_down_threshold}%"

  alarm_actions             = [aws_autoscaling_policy.scale_down_policy.arn] # Action to scale down
  insufficient_data_actions = []
}
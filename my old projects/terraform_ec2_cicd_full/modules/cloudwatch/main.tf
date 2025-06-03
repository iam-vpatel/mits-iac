
resource "aws_cloudwatch_log_group" "ec2_log_group" {
  name              = "/ec2/${var.name_prefix}"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${var.name_prefix}-cpu-util"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors high CPU usage"
  dimensions = {
    InstanceId = var.instance_id
  }
  alarm_actions = var.alarm_actions
}

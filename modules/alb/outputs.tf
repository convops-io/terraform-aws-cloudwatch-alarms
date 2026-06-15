output "five_xx_alarm_arns" {
  description = "ARNs of ALB 5XX alarms, keyed by ARN suffix."
  value       = { for k, v in aws_cloudwatch_metric_alarm.alb_5xx : k => v.arn }
}
output "response_time_alarm_arns" {
  description = "ARNs of ALB TargetResponseTime alarms, keyed by ARN suffix."
  value       = { for k, v in aws_cloudwatch_metric_alarm.alb_response_time : k => v.arn }
}
output "unhealthy_hosts_alarm_arns" {
  description = "ARNs of ALB UnHealthyHostCount alarms, keyed by ARN suffix."
  value       = { for k, v in aws_cloudwatch_metric_alarm.alb_unhealthy_hosts : k => v.arn }
}

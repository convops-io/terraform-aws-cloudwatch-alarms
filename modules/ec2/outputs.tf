output "cpu_alarm_arns" {
  description = "ARNs of EC2 CPU alarms, keyed by instance ID."
  value       = { for k, v in aws_cloudwatch_metric_alarm.ec2_cpu : k => v.arn }
}
output "status_check_alarm_arns" {
  description = "ARNs of EC2 StatusCheckFailed alarms, keyed by instance ID."
  value       = { for k, v in aws_cloudwatch_metric_alarm.ec2_status_check : k => v.arn }
}
output "network_in_alarm_arns" {
  description = "ARNs of EC2 NetworkIn alarms, keyed by instance ID."
  value       = { for k, v in aws_cloudwatch_metric_alarm.ec2_network_in : k => v.arn }
}
output "system_status_check_alarm_arns" {
  description = "ARNs of EC2 StatusCheckFailed_System alarms, keyed by instance ID."
  value       = { for k, v in aws_cloudwatch_metric_alarm.ec2_system_status_check : k => v.arn }
}

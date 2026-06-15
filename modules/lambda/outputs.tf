output "error_alarm_arns" {
  description = "ARNs of Lambda Errors alarms, keyed by function name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.lambda_errors : k => v.arn }
}
output "throttle_alarm_arns" {
  description = "ARNs of Lambda Throttles alarms, keyed by function name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.lambda_throttles : k => v.arn }
}
output "duration_alarm_arns" {
  description = "ARNs of Lambda Duration alarms, keyed by function name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.lambda_duration : k => v.arn }
}
output "concurrent_executions_alarm_arns" {
  description = "ARNs of Lambda ConcurrentExecutions alarms, keyed by function name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.lambda_concurrent_executions : k => v.arn }
}

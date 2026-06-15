output "throttle_alarm_arns" {
  description = "ARNs of DynamoDB ThrottledRequests alarms, keyed by table name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.dynamodb_throttles : k => v.arn }
}
output "consumed_read_capacity_alarm_arns" {
  description = "ARNs of DynamoDB ConsumedReadCapacityUnits alarms, keyed by table name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.dynamodb_consumed_read_capacity : k => v.arn }
}
output "system_errors_alarm_arns" {
  description = "ARNs of DynamoDB SystemErrors alarms, keyed by table name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.dynamodb_system_errors : k => v.arn }
}

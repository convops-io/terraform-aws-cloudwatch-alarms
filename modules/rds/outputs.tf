output "cpu_alarm_arns" {
  description = "ARNs of RDS CPU alarms, keyed by instance identifier."
  value       = { for k, v in aws_cloudwatch_metric_alarm.rds_cpu : k => v.arn }
}
output "connections_alarm_arns" {
  description = "ARNs of RDS DatabaseConnections alarms, keyed by instance identifier."
  value       = { for k, v in aws_cloudwatch_metric_alarm.rds_connections : k => v.arn }
}
output "free_storage_alarm_arns" {
  description = "ARNs of RDS FreeStorageSpace alarms, keyed by instance identifier."
  value       = { for k, v in aws_cloudwatch_metric_alarm.rds_free_storage : k => v.arn }
}
output "freeable_memory_alarm_arns" {
  description = "ARNs of RDS FreeableMemory alarms, keyed by instance identifier."
  value       = { for k, v in aws_cloudwatch_metric_alarm.rds_freeable_memory : k => v.arn }
}

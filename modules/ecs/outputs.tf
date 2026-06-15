output "cpu_alarm_arns" {
  description = "ARNs of ECS CPU alarms, keyed by service name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.ecs_cpu : k => v.arn }
}
output "memory_alarm_arns" {
  description = "ARNs of ECS Memory alarms, keyed by service name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.ecs_memory : k => v.arn }
}
output "running_tasks_alarm_arns" {
  description = "ARNs of ECS RunningTaskCount alarms, keyed by service name."
  value       = { for k, v in aws_cloudwatch_metric_alarm.ecs_running_tasks : k => v.arn }
}

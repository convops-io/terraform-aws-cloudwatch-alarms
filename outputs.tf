# ── RDS ───────────────────────────────────────────────────────────────────────

output "rds_cpu_alarm_arns" {
  description = "ARNs of RDS CPUUtilization alarms."
  value       = length(module.rds) > 0 ? module.rds[0].cpu_alarm_arns : {}
}
output "rds_connections_alarm_arns" {
  description = "ARNs of RDS DatabaseConnections alarms."
  value       = length(module.rds) > 0 ? module.rds[0].connections_alarm_arns : {}
}
output "rds_free_storage_alarm_arns" {
  description = "ARNs of RDS FreeStorageSpace alarms."
  value       = length(module.rds) > 0 ? module.rds[0].free_storage_alarm_arns : {}
}
output "rds_freeable_memory_alarm_arns" {
  description = "ARNs of RDS FreeableMemory alarms."
  value       = length(module.rds) > 0 ? module.rds[0].freeable_memory_alarm_arns : {}
}

# ── Lambda ────────────────────────────────────────────────────────────────────

output "lambda_error_alarm_arns" {
  description = "ARNs of Lambda Errors alarms."
  value       = length(module.lambda) > 0 ? module.lambda[0].error_alarm_arns : {}
}
output "lambda_throttle_alarm_arns" {
  description = "ARNs of Lambda Throttles alarms."
  value       = length(module.lambda) > 0 ? module.lambda[0].throttle_alarm_arns : {}
}
output "lambda_duration_alarm_arns" {
  description = "ARNs of Lambda Duration alarms."
  value       = length(module.lambda) > 0 ? module.lambda[0].duration_alarm_arns : {}
}
output "lambda_concurrent_executions_alarm_arns" {
  description = "ARNs of Lambda ConcurrentExecutions alarms."
  value       = length(module.lambda) > 0 ? module.lambda[0].concurrent_executions_alarm_arns : {}
}

# ── ECS ───────────────────────────────────────────────────────────────────────

output "ecs_cpu_alarm_arns" {
  description = "ARNs of ECS CPUUtilization alarms."
  value       = length(module.ecs) > 0 ? module.ecs[0].cpu_alarm_arns : {}
}
output "ecs_memory_alarm_arns" {
  description = "ARNs of ECS MemoryUtilization alarms."
  value       = length(module.ecs) > 0 ? module.ecs[0].memory_alarm_arns : {}
}
output "ecs_running_tasks_alarm_arns" {
  description = "ARNs of ECS RunningTaskCount alarms."
  value       = length(module.ecs) > 0 ? module.ecs[0].running_tasks_alarm_arns : {}
}

# ── ALB ───────────────────────────────────────────────────────────────────────

output "alb_5xx_alarm_arns" {
  description = "ARNs of ALB 5XX alarms."
  value       = length(module.alb) > 0 ? module.alb[0].five_xx_alarm_arns : {}
}
output "alb_response_time_alarm_arns" {
  description = "ARNs of ALB TargetResponseTime alarms."
  value       = length(module.alb) > 0 ? module.alb[0].response_time_alarm_arns : {}
}
output "alb_unhealthy_hosts_alarm_arns" {
  description = "ARNs of ALB UnHealthyHostCount alarms."
  value       = length(module.alb) > 0 ? module.alb[0].unhealthy_hosts_alarm_arns : {}
}

# ── EC2 ───────────────────────────────────────────────────────────────────────

output "ec2_cpu_alarm_arns" {
  description = "ARNs of EC2 CPUUtilization alarms."
  value       = length(module.ec2) > 0 ? module.ec2[0].cpu_alarm_arns : {}
}
output "ec2_status_check_alarm_arns" {
  description = "ARNs of EC2 StatusCheckFailed alarms."
  value       = length(module.ec2) > 0 ? module.ec2[0].status_check_alarm_arns : {}
}
output "ec2_network_in_alarm_arns" {
  description = "ARNs of EC2 NetworkIn alarms."
  value       = length(module.ec2) > 0 ? module.ec2[0].network_in_alarm_arns : {}
}
output "ec2_system_status_check_alarm_arns" {
  description = "ARNs of EC2 StatusCheckFailed_System (hardware) alarms."
  value       = length(module.ec2) > 0 ? module.ec2[0].system_status_check_alarm_arns : {}
}

# ── DynamoDB ──────────────────────────────────────────────────────────────────

output "dynamodb_throttle_alarm_arns" {
  description = "ARNs of DynamoDB ThrottledRequests alarms."
  value       = length(module.dynamodb) > 0 ? module.dynamodb[0].throttle_alarm_arns : {}
}
output "dynamodb_consumed_read_capacity_alarm_arns" {
  description = "ARNs of DynamoDB ConsumedReadCapacityUnits alarms. Empty if dynamodb_consumed_read_capacity_threshold is 0 (default)."
  value       = length(module.dynamodb) > 0 ? module.dynamodb[0].consumed_read_capacity_alarm_arns : {}
}
output "dynamodb_system_errors_alarm_arns" {
  description = "ARNs of DynamoDB SystemErrors alarms."
  value       = length(module.dynamodb) > 0 ? module.dynamodb[0].system_errors_alarm_arns : {}
}

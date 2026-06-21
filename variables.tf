# ── Mode ──────────────────────────────────────────────────────────────────────

variable "auto_discover" {
  description = "Automatically discover resources in your AWS account using data sources. RDS, EC2, and ALB are fully supported with optional tag filters. ECS services are discovered via the Resource Groups Tagging API filtered by cluster name. Lambda and DynamoDB require static config — no list data source exists for them."
  type        = bool
  default     = false
}

# ── Resource identifiers (used when auto_discover = false) ────────────────────

variable "rds_instance_identifiers" {
  description = "List of RDS instance identifiers to create alarms for."
  type        = list(string)
  default     = []
}

variable "lambda_function_names" {
  description = "List of Lambda function names to create alarms for."
  type        = list(string)
  default     = []
}

variable "ecs_cluster_name" {
  description = "ECS cluster name. Required if ecs_service_names is set."
  type        = string
  default     = ""
}

variable "ecs_service_names" {
  description = "List of ECS service names to create alarms for. Requires ecs_cluster_name."
  type        = list(string)
  default     = []
}

variable "alb_arn_suffixes" {
  description = "List of ALB ARN suffixes (the portion after 'loadbalancer/'). Found in the ALB console or via aws elbv2 describe-load-balancers."
  type        = list(string)
  default     = []
}

variable "ec2_instance_ids" {
  description = "List of EC2 instance IDs to create alarms for."
  type        = list(string)
  default     = []
}

variable "dynamodb_table_names" {
  description = "List of DynamoDB table names to create alarms for."
  type        = list(string)
  default     = []
}

# ── Auto-discovery filters (used when auto_discover = true) ───────────────────

variable "rds_filter_tags" {
  description = "Tag filters for RDS auto-discovery. Example: { Environment = \"prod\" }"
  type        = map(string)
  default     = {}
}

variable "ec2_filter_tags" {
  description = "Tag filters for EC2 auto-discovery. Example: { Environment = \"prod\" }"
  type        = map(string)
  default     = {}
}

variable "alb_filter_tags" {
  description = "Tag filters for ALB auto-discovery. Example: { Environment = \"prod\" }"
  type        = map(string)
  default     = {}
}

variable "ecs_auto_discover_cluster_name" {
  description = "ECS cluster name for auto-discovery. Required when auto_discover = true and you want ECS alarms. Services are discovered via the Resource Groups Tagging API filtered to this cluster name."
  type        = string
  default     = ""
}

variable "ecs_filter_tags" {
  description = "Tag filters for ECS auto-discovery. Narrows which services are discovered within the cluster. Example: { Environment = \"prod\" }"
  type        = map(string)
  default     = {}
}

# ── Alarm actions ─────────────────────────────────────────────────────────────

variable "alarm_actions" {
  description = "List of ARNs to notify when an alarm transitions to ALARM state (e.g. SNS topic ARN). Leave empty to create alarms with no action."
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when an alarm transitions to OK state."
  type        = list(string)
  default     = []
}

variable "insufficient_data_actions" {
  description = "List of ARNs to notify when an alarm transitions to INSUFFICIENT_DATA state."
  type        = list(string)
  default     = []
}

# ── ConvOps integration ───────────────────────────────────────────────────────

variable "enable_convops" {
  description = "Append a ConvOps diagnosis link to all alarm descriptions. When an alarm fires, engineers see a direct link to connect their AWS account for automated root cause analysis at convops.io/audit. No infrastructure change — description text only."
  type        = bool
  default     = false
}

# ── Thresholds — RDS ─────────────────────────────────────────────────────────

variable "rds_cpu_threshold" {
  description = "RDS CPUUtilization alarm threshold (percent). Alarm fires when CPU exceeds this for 3 consecutive 5-minute periods."
  type        = number
  default     = 80
  validation {
    condition     = var.rds_cpu_threshold > 0 && var.rds_cpu_threshold <= 100
    error_message = "rds_cpu_threshold must be between 1 and 100."
  }
}

variable "rds_connections_threshold" {
  description = "RDS DatabaseConnections alarm threshold (count). Set to 80% of your instance's max_connections. Default 100 — override for your instance class."
  type        = number
  default     = 100
}

variable "rds_free_storage_threshold" {
  description = "RDS FreeStorageSpace alarm threshold (bytes). Default 10 GB."
  type        = number
  default     = 10000000000
}

variable "rds_freeable_memory_threshold" {
  description = "RDS FreeableMemory alarm threshold (bytes). Default 256 MB."
  type        = number
  default     = 268435456
}

# ── Thresholds — Lambda ───────────────────────────────────────────────────────

variable "lambda_error_threshold" {
  description = "Lambda Errors alarm threshold (count). Default 0 — any error triggers the alarm."
  type        = number
  default     = 0
}

variable "lambda_throttle_threshold" {
  description = "Lambda Throttles alarm threshold (count). Default 0 — any throttle triggers the alarm."
  type        = number
  default     = 0
}

variable "lambda_duration_percent_threshold" {
  description = "Lambda Duration alarm threshold as a percentage of the function timeout. Default 80 — alarm fires when p99 duration exceeds 80% of timeout."
  type        = number
  default     = 80
  validation {
    condition     = var.lambda_duration_percent_threshold > 0 && var.lambda_duration_percent_threshold <= 100
    error_message = "lambda_duration_percent_threshold must be between 1 and 100."
  }
}

variable "lambda_concurrent_executions_threshold" {
  description = "Lambda ConcurrentExecutions alarm threshold (count). Default 800 — 80% of the default AWS account limit of 1000."
  type        = number
  default     = 800
}

variable "lambda_timeouts" {
  description = "Map of Lambda function name to timeout in milliseconds. Used to calculate the duration threshold per function. Example: { my-function = 30000 }"
  type        = map(number)
  default     = {}
}

# ── Thresholds — ECS ─────────────────────────────────────────────────────────

variable "ecs_cpu_threshold" {
  description = "ECS CPUUtilization alarm threshold (percent). Default 80."
  type        = number
  default     = 80
  validation {
    condition     = var.ecs_cpu_threshold > 0 && var.ecs_cpu_threshold <= 100
    error_message = "ecs_cpu_threshold must be between 1 and 100."
  }
}

variable "ecs_memory_threshold" {
  description = "ECS MemoryUtilization alarm threshold (percent). Default 85."
  type        = number
  default     = 85
  validation {
    condition     = var.ecs_memory_threshold > 0 && var.ecs_memory_threshold <= 100
    error_message = "ecs_memory_threshold must be between 1 and 100."
  }
}

variable "ecs_running_task_min_count" {
  description = "Map of ECS service name to minimum acceptable running task count. Alarm fires when running tasks drop below this. Example: { api = 2, worker = 1 }"
  type        = map(number)
  default     = {}
}

# ── Thresholds — ALB ─────────────────────────────────────────────────────────

variable "alb_5xx_threshold" {
  description = "ALB HTTPCode_ELB_5XX_Count alarm threshold (count per minute). Default 10."
  type        = number
  default     = 10
}

variable "alb_response_time_threshold" {
  description = "ALB TargetResponseTime p99 alarm threshold (seconds). Default 2."
  type        = number
  default     = 2
  validation {
    condition     = var.alb_response_time_threshold > 0
    error_message = "alb_response_time_threshold must be greater than 0."
  }
}

variable "alb_unhealthy_host_threshold" {
  description = "ALB UnHealthyHostCount alarm threshold (count). Default 0 — any unhealthy host triggers alarm."
  type        = number
  default     = 0
}

# ── Thresholds — EC2 ─────────────────────────────────────────────────────────

variable "ec2_cpu_threshold" {
  description = "EC2 CPUUtilization alarm threshold (percent). Default 85."
  type        = number
  default     = 85
  validation {
    condition     = var.ec2_cpu_threshold > 0 && var.ec2_cpu_threshold <= 100
    error_message = "ec2_cpu_threshold must be between 1 and 100."
  }
}

variable "ec2_network_in_min_threshold" {
  description = "EC2 NetworkIn minimum threshold (bytes). Alarm fires when NetworkIn drops below this — signals traffic has stopped. Default 1000 bytes."
  type        = number
  default     = 1000
}

# ── Thresholds — DynamoDB ─────────────────────────────────────────────────────

variable "dynamodb_throttle_threshold" {
  description = "DynamoDB ThrottledRequests alarm threshold (count). Default 0 — any throttle triggers alarm."
  type        = number
  default     = 0
}

variable "dynamodb_consumed_read_capacity_threshold" {
  description = "DynamoDB ConsumedReadCapacityUnits alarm threshold (count per minute). Override with 80% of your provisioned RCU. Default 0 disables this alarm — you must set it for your table."
  type        = number
  default     = 0
  validation {
    condition     = var.dynamodb_consumed_read_capacity_threshold >= 0
    error_message = "dynamodb_consumed_read_capacity_threshold must be 0 (disabled) or a positive number."
  }
}

# ── Tags ──────────────────────────────────────────────────────────────────────

variable "tags" {
  description = "Tags to apply to all CloudWatch alarms created by this module."
  type        = map(string)
  default     = {}
}

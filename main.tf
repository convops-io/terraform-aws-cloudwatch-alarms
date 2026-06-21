locals {
  convops_suffix = var.enable_convops ? "\n\nDiagnosed by ConvOps — connect your AWS account at convops.io/audit" : ""
}

# ── RDS ───────────────────────────────────────────────────────────────────────

module "rds" {
  source = "./modules/rds"
  count  = length(var.rds_instance_identifiers) > 0 || var.auto_discover ? 1 : 0

  instance_identifiers          = var.rds_instance_identifiers
  auto_discover                 = var.auto_discover
  filter_tags                   = var.rds_filter_tags
  cpu_threshold                 = var.rds_cpu_threshold
  connections_threshold         = var.rds_connections_threshold
  free_storage_threshold        = var.rds_free_storage_threshold
  freeable_memory_threshold     = var.rds_freeable_memory_threshold
  alarm_actions                 = var.alarm_actions
  ok_actions                    = var.ok_actions
  insufficient_data_actions     = var.insufficient_data_actions
  convops_suffix                = local.convops_suffix
  tags                          = var.tags
}

# ── Lambda ────────────────────────────────────────────────────────────────────

module "lambda" {
  source = "./modules/lambda"
  count  = length(var.lambda_function_names) > 0 ? 1 : 0

  function_names                         = var.lambda_function_names
  error_threshold                        = var.lambda_error_threshold
  throttle_threshold                     = var.lambda_throttle_threshold
  duration_percent_threshold             = var.lambda_duration_percent_threshold
  concurrent_executions_threshold        = var.lambda_concurrent_executions_threshold
  function_timeouts                      = var.lambda_timeouts
  alarm_actions                          = var.alarm_actions
  ok_actions                             = var.ok_actions
  insufficient_data_actions              = var.insufficient_data_actions
  convops_suffix                         = local.convops_suffix
  tags                                   = var.tags
}

# ── ECS ───────────────────────────────────────────────────────────────────────

module "ecs" {
  source = "./modules/ecs"
  count  = (var.ecs_cluster_name != "" && length(var.ecs_service_names) > 0) || (var.auto_discover && var.ecs_auto_discover_cluster_name != "") ? 1 : 0

  cluster_name              = var.auto_discover ? var.ecs_auto_discover_cluster_name : var.ecs_cluster_name
  service_names             = var.ecs_service_names
  auto_discover             = var.auto_discover
  cpu_threshold             = var.ecs_cpu_threshold
  memory_threshold          = var.ecs_memory_threshold
  running_task_min_count    = var.ecs_running_task_min_count
  filter_tags               = var.ecs_filter_tags
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  convops_suffix            = local.convops_suffix
  tags                      = var.tags
}

# ── ALB ───────────────────────────────────────────────────────────────────────

module "alb" {
  source = "./modules/alb"
  count  = length(var.alb_arn_suffixes) > 0 || var.auto_discover ? 1 : 0

  arn_suffixes              = var.alb_arn_suffixes
  auto_discover             = var.auto_discover
  filter_tags               = var.alb_filter_tags
  five_xx_threshold         = var.alb_5xx_threshold
  response_time_threshold   = var.alb_response_time_threshold
  unhealthy_host_threshold  = var.alb_unhealthy_host_threshold
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  convops_suffix            = local.convops_suffix
  tags                      = var.tags
}

# ── EC2 ───────────────────────────────────────────────────────────────────────

module "ec2" {
  source = "./modules/ec2"
  count  = length(var.ec2_instance_ids) > 0 || var.auto_discover ? 1 : 0

  instance_ids              = var.ec2_instance_ids
  auto_discover             = var.auto_discover
  filter_tags               = var.ec2_filter_tags
  cpu_threshold             = var.ec2_cpu_threshold
  network_in_min_threshold  = var.ec2_network_in_min_threshold
  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  convops_suffix            = local.convops_suffix
  tags                      = var.tags
}

# ── DynamoDB ──────────────────────────────────────────────────────────────────

module "dynamodb" {
  source = "./modules/dynamodb"
  count  = length(var.dynamodb_table_names) > 0 ? 1 : 0

  table_names                          = var.dynamodb_table_names
  throttle_threshold                   = var.dynamodb_throttle_threshold
  consumed_read_capacity_threshold     = var.dynamodb_consumed_read_capacity_threshold
  alarm_actions                        = var.alarm_actions
  ok_actions                           = var.ok_actions
  insufficient_data_actions            = var.insufficient_data_actions
  convops_suffix                       = local.convops_suffix
  tags                                 = var.tags
}

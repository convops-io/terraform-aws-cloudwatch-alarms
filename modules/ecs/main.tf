# Auto-discovery: find ECS services via Resource Groups Tagging API,
# filtered to the specified cluster by matching its name in the service ARN.
data "aws_resourcegroupstaggingapi_resources" "ecs_services" {
  count                 = var.auto_discover && length(var.service_names) == 0 && var.cluster_name != "" ? 1 : 0
  resource_type_filters = ["ecs:service"]

  dynamic "tag_filter" {
    for_each = var.filter_tags
    content {
      key    = tag_filter.key
      values = [tag_filter.value]
    }
  }
}

locals {
  # Filter returned ARNs to only services in the specified cluster, then
  # extract the service name (last path segment of the ARN).
  discovered_services = var.auto_discover && length(var.service_names) == 0 && var.cluster_name != "" ? [
    for arn in data.aws_resourcegroupstaggingapi_resources.ecs_services[0].resource_tag_mapping_list[*].resource_arn :
    regex("[^/]+$", arn)
    if can(regex("/${var.cluster_name}/", arn))
  ] : []
  service_names = length(var.service_names) > 0 ? var.service_names : local.discovered_services
}

# ── CPU Utilization ───────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  for_each = toset(local.service_names)

  alarm_name          = "ecs-${var.cluster_name}-${each.key}-cpu-high"
  alarm_description   = "ECS service ${each.key} CPU above ${var.cpu_threshold}%. Check for traffic spike, memory pressure causing swap, or a runaway process in a container.${var.convops_suffix}"
  namespace           = "AWS/ECS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = var.cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Memory Utilization ────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  for_each = toset(local.service_names)

  alarm_name          = "ecs-${var.cluster_name}-${each.key}-memory-high"
  alarm_description   = "ECS service ${each.key} memory above ${var.memory_threshold}%. OOM kills begin when memory reaches 100%. At 85% you have time to act before tasks start restarting.${var.convops_suffix}"
  namespace           = "AWS/ECS"
  metric_name         = "MemoryUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = var.memory_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Running Task Count ────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ecs_running_tasks" {
  for_each = toset(local.service_names)

  alarm_name          = "ecs-${var.cluster_name}-${each.key}-running-tasks-low"
  alarm_description   = "ECS service ${each.key} running tasks below minimum. Tasks may be crash-looping, failing health checks, or hitting OOM. Check task stopped reason in ECS console.${var.convops_suffix}"
  namespace           = "AWS/ECS"
  metric_name         = "RunningTaskCount"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  threshold           = lookup(var.running_task_min_count, each.key, 1)
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

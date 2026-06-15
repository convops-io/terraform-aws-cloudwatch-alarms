locals {
  # Auto-discovery: use data source if auto_discover=true and no explicit IDs given
  discovered_ids = var.auto_discover && length(var.instance_identifiers) == 0 ? [
    for db in data.aws_db_instances.all[0].instance_identifiers : db
  ] : []
  instance_ids = length(var.instance_identifiers) > 0 ? var.instance_identifiers : local.discovered_ids
}

data "aws_db_instances" "all" {
  count = var.auto_discover && length(var.instance_identifiers) == 0 ? 1 : 0

  dynamic "filter" {
    for_each = var.filter_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

# ── CPU Utilization ───────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  for_each = toset(local.instance_ids)

  alarm_name          = "rds-${each.key}-cpu-high"
  alarm_description   = "RDS CPU above ${var.cpu_threshold}% for 15 minutes. Check for long-running queries, missing indexes, or connection spikes.${var.convops_suffix}"
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = var.cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Database Connections ──────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  for_each = toset(local.instance_ids)

  alarm_name          = "rds-${each.key}-connections-high"
  alarm_description   = "RDS DatabaseConnections above ${var.connections_threshold}. Set threshold to 80% of your instance's max_connections. Connection saturation causes new connections to fail.${var.convops_suffix}"
  namespace           = "AWS/RDS"
  metric_name         = "DatabaseConnections"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.connections_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Free Storage Space ────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "rds_free_storage" {
  for_each = toset(local.instance_ids)

  alarm_name          = "rds-${each.key}-free-storage-low"
  alarm_description   = "RDS FreeStorageSpace below ${var.free_storage_threshold / 1000000000}GB. Running out of storage causes the instance to become read-only. Act before it reaches 0.${var.convops_suffix}"
  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.free_storage_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Freeable Memory ───────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "rds_freeable_memory" {
  for_each = toset(local.instance_ids)

  alarm_name          = "rds-${each.key}-freeable-memory-low"
  alarm_description   = "RDS FreeableMemory below ${var.freeable_memory_threshold / 1048576}MB. Low memory increases disk swap, degrading query performance significantly.${var.convops_suffix}"
  namespace           = "AWS/RDS"
  metric_name         = "FreeableMemory"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = var.freeable_memory_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

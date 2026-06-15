# ── Throttled Requests ────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  for_each = toset(var.table_names)

  alarm_name          = "dynamodb-${each.key}-throttled-requests"
  alarm_description   = "DynamoDB table ${each.key} has throttled requests. Requests are being rejected. Common causes: hot partition keys, burst capacity exhausted, or provisioned throughput too low.${var.convops_suffix}"
  namespace           = "AWS/DynamoDB"
  metric_name         = "ThrottledRequests"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = var.throttle_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Consumed Read Capacity ────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "dynamodb_consumed_read_capacity" {
  # Only create if threshold is set — must be configured per table
  for_each = toset([for t in var.table_names : t if var.consumed_read_capacity_threshold > 0])

  alarm_name          = "dynamodb-${each.key}-consumed-read-capacity-high"
  alarm_description   = "DynamoDB table ${each.key} ConsumedReadCapacityUnits above ${var.consumed_read_capacity_threshold}/min. Set this to 80% of your provisioned RCU. Approaching limit risks throttling and cost spikes from on-demand bursting.${var.convops_suffix}"
  namespace           = "AWS/DynamoDB"
  metric_name         = "ConsumedReadCapacityUnits"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 5
  threshold           = var.consumed_read_capacity_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── System Errors ─────────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "dynamodb_system_errors" {
  for_each = toset(var.table_names)

  alarm_name          = "dynamodb-${each.key}-system-errors"
  alarm_description   = "DynamoDB table ${each.key} has system errors (5xx from AWS). This is an AWS-side issue, not a client error. Usually transient — if sustained, check AWS Health Dashboard.${var.convops_suffix}"
  namespace           = "AWS/DynamoDB"
  metric_name         = "SystemErrors"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 3
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

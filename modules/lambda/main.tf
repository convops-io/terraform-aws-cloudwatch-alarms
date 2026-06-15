locals {
  # Default timeout: 30s (30000ms) if not specified per function
  default_timeout_ms = 30000
}

# ── Errors ────────────────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = toset(var.function_names)

  alarm_name          = "lambda-${each.key}-errors"
  alarm_description   = "Lambda ${each.key} errors detected. Any error count above ${var.error_threshold} triggers this alarm. Check CloudWatch Logs for stack traces.${var.convops_suffix}"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = var.error_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Throttles ─────────────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  for_each = toset(var.function_names)

  alarm_name          = "lambda-${each.key}-throttles"
  alarm_description   = "Lambda ${each.key} throttles detected. Requests are being dropped. Increase reserved concurrency or request a limit increase.${var.convops_suffix}"
  namespace           = "AWS/Lambda"
  metric_name         = "Throttles"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = var.throttle_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Duration (p99 vs timeout) ─────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  for_each = toset(var.function_names)

  alarm_name = "lambda-${each.key}-duration-high"
  alarm_description = "Lambda ${each.key} p99 duration above ${var.duration_percent_threshold}% of its timeout. Functions approaching timeout are at risk of silent failure. Check for slow downstream calls or processing loops.${var.convops_suffix}"
  namespace           = "AWS/Lambda"
  metric_name         = "Duration"
  extended_statistic  = "p99"
  period              = 300
  evaluation_periods  = 3
  # Threshold = timeout_ms * (percent / 100). Falls back to default_timeout if not specified.
  threshold           = lookup(var.function_timeouts, each.key, local.default_timeout_ms) * (var.duration_percent_threshold / 100)
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Concurrent Executions ─────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "lambda_concurrent_executions" {
  for_each = toset(var.function_names)

  alarm_name          = "lambda-${each.key}-concurrent-executions-high"
  alarm_description   = "Lambda ${each.key} concurrent executions above ${var.concurrent_executions_threshold}. Approaching the account-level concurrency limit. Throttling will occur at the limit.${var.convops_suffix}"
  namespace           = "AWS/Lambda"
  metric_name         = "ConcurrentExecutions"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 5
  threshold           = var.concurrent_executions_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

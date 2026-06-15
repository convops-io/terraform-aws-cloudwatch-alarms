locals {
  discovered_suffixes = var.auto_discover && length(var.arn_suffixes) == 0 ? [
    for lb in data.aws_lbs.all[0].arns : regex("loadbalancer/(.+)$", lb)[0]
  ] : []
  arn_suffixes = length(var.arn_suffixes) > 0 ? var.arn_suffixes : local.discovered_suffixes
}

data "aws_lbs" "all" {
  count = var.auto_discover && length(var.arn_suffixes) == 0 ? 1 : 0

  tags = var.filter_tags
}

# ── 5XX Errors ────────────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  for_each = toset(local.arn_suffixes)

  alarm_name          = "alb-${replace(each.key, "/", "-")}-5xx-high"
  alarm_description   = "ALB 5XX errors above ${var.five_xx_threshold}/min. Check target health, recent deploys, and upstream timeouts. 5XXs from the ALB itself (not targets) indicate capacity or misconfiguration issues.${var.convops_suffix}"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 3
  threshold           = var.five_xx_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Target Response Time (p99) ────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
  for_each = toset(local.arn_suffixes)

  alarm_name          = "alb-${replace(each.key, "/", "-")}-response-time-high"
  alarm_description   = "ALB p99 response time above ${var.response_time_threshold}s. 1% of requests are experiencing high latency. Check slow targets, database queries, or downstream API timeouts.${var.convops_suffix}"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  extended_statistic  = "p99"
  period              = 300
  evaluation_periods  = 3
  threshold           = var.response_time_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Unhealthy Host Count ──────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  for_each = toset(local.arn_suffixes)

  alarm_name          = "alb-${replace(each.key, "/", "-")}-unhealthy-hosts"
  alarm_description   = "ALB has unhealthy targets. Requests are being routed to fewer healthy targets, increasing load on remaining ones. If all targets fail health checks, the service goes down.${var.convops_suffix}"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = var.unhealthy_host_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

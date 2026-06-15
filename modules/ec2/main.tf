locals {
  discovered_ids = var.auto_discover && length(var.instance_ids) == 0 ? tolist(data.aws_instances.all[0].ids) : []
  instance_ids   = length(var.instance_ids) > 0 ? var.instance_ids : local.discovered_ids
}

data "aws_instances" "all" {
  count = var.auto_discover && length(var.instance_ids) == 0 ? 1 : 0

  dynamic "filter" {
    for_each = var.filter_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

# ── CPU Utilization ───────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  for_each = toset(local.instance_ids)

  alarm_name          = "ec2-${each.key}-cpu-high"
  alarm_description   = "EC2 instance ${each.key} CPU above ${var.cpu_threshold}% for 15 minutes. Sustained high CPU degrades response times and can cause OOM on memory-constrained instances.${var.convops_suffix}"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = var.cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Status Check Failed ───────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ec2_status_check" {
  for_each = toset(local.instance_ids)

  alarm_name          = "ec2-${each.key}-status-check-failed"
  alarm_description   = "EC2 instance ${each.key} status check failed. This covers both system status (AWS hardware) and instance status (OS). A failed system check requires AWS involvement. A failed instance check requires OS-level recovery.${var.convops_suffix}"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── Network In (traffic stopped signal) ──────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ec2_network_in" {
  for_each = toset(local.instance_ids)

  alarm_name          = "ec2-${each.key}-network-in-low"
  alarm_description   = "EC2 instance ${each.key} NetworkIn near zero. Inbound traffic has effectively stopped. Check security groups, route tables, load balancer health, and whether the process is still listening.${var.convops_suffix}"
  namespace           = "AWS/EC2"
  metric_name         = "NetworkIn"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = var.network_in_min_threshold
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

# ── System Status Check Failed (hardware) ────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ec2_system_status_check" {
  for_each = toset(local.instance_ids)

  alarm_name          = "ec2-${each.key}-system-status-check-failed"
  alarm_description   = "EC2 instance ${each.key} system status check failed. This indicates an AWS hardware or infrastructure issue. Stop and start the instance to migrate it to new hardware.${var.convops_suffix}"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_System"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId = each.key
  }

  alarm_actions             = var.alarm_actions
  ok_actions                = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions

  tags = var.tags
}

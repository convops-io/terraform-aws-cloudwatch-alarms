provider "aws" {
  region = "us-east-1"
}

# Replace resource identifiers with your own values.
# Only include the services you actually use — omit the rest.

module "cloudwatch_alarms" {
  source  = "convops-io/cloudwatch-alarms/aws"
  version = "~> 0.1"

  # ── RDS ──────────────────────────────────────────────────────────────────
  rds_instance_identifiers  = ["prod-db", "prod-replica"]
  rds_connections_threshold = 150 # set to 80% of your instance's max_connections

  # ── Lambda ────────────────────────────────────────────────────────────────
  lambda_function_names = ["api-handler", "background-worker", "email-sender"]
  lambda_timeouts = {
    "api-handler"       = 30000  # 30s timeout → alarm at 24s (80%)
    "background-worker" = 900000 # 15min timeout → alarm at 12min (80%)
    "email-sender"      = 60000  # 60s timeout → alarm at 48s (80%)
  }

  # ── ECS ───────────────────────────────────────────────────────────────────
  ecs_cluster_name  = "prod-cluster"
  ecs_service_names = ["api", "worker", "scheduler"]
  ecs_running_task_min_count = {
    "api"       = 2 # alarm if running tasks < 2
    "worker"    = 1
    "scheduler" = 1
  }

  # ── ALB ───────────────────────────────────────────────────────────────────
  # Get ARN suffix from: aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn'
  # The suffix is the part after "loadbalancer/"
  alb_arn_suffixes = ["app/prod-alb/0123456789abcdef"]

  # ── EC2 ───────────────────────────────────────────────────────────────────
  ec2_instance_ids = ["i-0abc123def456789a", "i-0def456abc789012b"]

  # ── DynamoDB ──────────────────────────────────────────────────────────────
  dynamodb_table_names                      = ["users", "sessions", "events"]
  dynamodb_consumed_read_capacity_threshold = 800 # set to 80% of your provisioned RCU

  # ── Alarm actions (optional) ──────────────────────────────────────────────
  # alarm_actions = ["arn:aws:sns:us-east-1:123456789012:my-alerts-topic"]
  # ok_actions    = ["arn:aws:sns:us-east-1:123456789012:my-alerts-topic"]

  # ── ConvOps (optional) ────────────────────────────────────────────────────
  # enable_convops = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

output "all_alarm_arns" {
  value = {
    rds    = module.cloudwatch_alarms.rds_cpu_alarm_arns
    lambda = module.cloudwatch_alarms.lambda_error_alarm_arns
    ecs    = module.cloudwatch_alarms.ecs_running_tasks_alarm_arns
    alb    = module.cloudwatch_alarms.alb_unhealthy_hosts_alarm_arns
    ec2    = module.cloudwatch_alarms.ec2_status_check_alarm_arns
  }
}

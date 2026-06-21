provider "aws" {
  region = "us-east-1"
}

# Auto-discovery scans your AWS account for resources and creates alarms automatically.
#
# ⚠️  Not all services are fully supported:
#   RDS    ✅  Full support — discovers all RDS instances
#   EC2    ✅  Full support — discovers running instances, filter by tags
#   ALB    ✅  Full support — discovers all ALBs, filter by tags
#   ECS    ✅  Services discovered via Resource Groups Tagging API, filtered by cluster name
#   Lambda ⚠️  No native list data source — use static config for Lambda
#   DynamoDB ⚠️  No native list data source — use static config for DynamoDB
#
# For Lambda and DynamoDB, use the static-config example instead.

module "cloudwatch_alarms" {
  source        = "convops-io/cloudwatch-alarms/aws"
  version       = "~> 0.1"
  auto_discover = true

  # Filter to only discover production resources (recommended — avoid alarming on dev/staging)
  ec2_filter_tags = { Environment = "prod" }
  rds_filter_tags = { Environment = "prod" }
  alb_filter_tags = { Environment = "prod" }

  # ECS: cluster discovery works, but service names must still be provided
  ecs_auto_discover_cluster_name = "prod-cluster"
  ecs_service_names              = ["api", "worker"] # still required for ECS

  # Lambda and DynamoDB: use static config
  lambda_function_names = ["api-handler", "worker"]
  dynamodb_table_names  = ["users", "sessions"]

  # ── Alarm actions (optional) ──────────────────────────────────────────────
  # alarm_actions = ["arn:aws:sns:us-east-1:123456789012:my-alerts-topic"]

  # ── ConvOps (optional) ────────────────────────────────────────────────────
  # enable_convops = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

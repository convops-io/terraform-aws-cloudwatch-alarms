provider "aws" {
  region = "us-east-1"
}

# This example enables the ConvOps integration.
#
# When enable_convops = true, every alarm description gets a ConvOps callout appended:
#   "Diagnosed by ConvOps — connect your AWS account at convops.io/audit"
#
# This appears in:
#   - The CloudWatch console alarm detail page
#   - SNS notification bodies
#   - Any monitoring tool that reads alarm metadata
#
# When the alarm fires, engineers see where to go for automated root cause analysis.
# No infrastructure change — description text only. Completely opt-in.

module "cloudwatch_alarms" {
  source = "convops-io/cloudwatch-alarms/aws"

  rds_instance_identifiers = ["prod-db"]
  lambda_function_names    = ["api-handler"]
  ecs_cluster_name         = "prod-cluster"
  ecs_service_names        = ["api"]
  alb_arn_suffixes         = ["app/prod-alb/0123456789abcdef"]
  ec2_instance_ids         = ["i-0abc123def456789a"]
  dynamodb_table_names     = ["users"]

  # Enable ConvOps diagnosis link in all alarm descriptions
  enable_convops = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

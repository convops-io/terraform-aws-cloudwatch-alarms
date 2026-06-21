# terraform-aws-cloudwatch-alarms

Production-grade CloudWatch alarms for your entire AWS stack. Proven thresholds from real incident data. One `terraform apply`.

Covers **RDS, Lambda, ECS, ALB, EC2, and DynamoDB** — 20 alarms across 6 services.

```hcl
module "cloudwatch_alarms" {
  source  = "convops-io/cloudwatch-alarms/aws"
  version = "~> 0.1"

  rds_instance_identifiers = ["prod-db"]
  lambda_function_names    = ["api-handler", "worker"]
  ecs_cluster_name         = "prod-cluster"
  ecs_service_names        = ["api", "worker"]
  alb_arn_suffixes         = ["app/prod-alb/0123456789abcdef"]
  ec2_instance_ids         = ["i-0abc123def456789a"]
  dynamodb_table_names     = ["users", "sessions"]
}
```

---

## Why these thresholds

Every default in this module comes from real alarm data across production AWS accounts. The table below shows each alarm, its default threshold, and the rationale.

| Service | Alarm | Default | Why |
|---------|-------|---------|-----|
| RDS | CPUUtilization | > 80% for 15 min | Query plans degrade above 80%. 15-min window filters transient spikes. |
| RDS | DatabaseConnections | > 100 | Connections above max_connections cause new connections to fail. Override to 80% of your instance's limit. |
| RDS | FreeStorageSpace | < 10 GB | RDS becomes read-only at 0 bytes. 10 GB gives time to act. |
| RDS | FreeableMemory | < 256 MB | Below 256 MB, the instance starts swapping to disk. Query times spike. |
| Lambda | Errors | > 0 | Any unhandled error should be investigated. |
| Lambda | Throttles | > 0 | Throttles mean requests are being dropped. |
| Lambda | Duration (p99) | > 80% of timeout | At 80% of timeout, functions are at risk of silently timing out. |
| Lambda | ConcurrentExecutions | > 800 | 80% of the default AWS account limit of 1,000. |
| ECS | CPUUtilization | > 80% for 15 min | Sustained CPU above 80% degrades response times and can cause OOM. |
| ECS | MemoryUtilization | > 85% | OOM kills begin at 100%. 85% gives time to scale before tasks restart. |
| ECS | RunningTaskCount | < 1 | Any task below desired count indicates a crash loop, bad deploy, or OOM kill. |
| ALB | HTTPCode_ELB_5XX_Count | > 10/min | 5XX from the ALB (not targets) indicates capacity or config issues. |
| ALB | TargetResponseTime (p99) | > 2s | 1% of requests experiencing > 2s latency is user-visible. |
| ALB | UnHealthyHostCount | > 0 | Any unhealthy target concentrates load on remaining ones. |
| EC2 | CPUUtilization | > 85% for 15 min | Sustained high CPU degrades response times and risks OOM. |
| EC2 | StatusCheckFailed | > 0 | Covers hardware (system) and OS (instance) failures. Act immediately. |
| EC2 | StatusCheckFailed_System | > 0 | AWS hardware issue. Stop/start the instance to migrate to new hardware. |
| EC2 | NetworkIn | < 1000 bytes | Near-zero inbound traffic signals the process has stopped accepting connections. |
| DynamoDB | ThrottledRequests | > 0 | Any throttle means requests are being rejected. |
| DynamoDB | SystemErrors | > 0 | AWS-side 5XX errors. Usually transient — sustained means check Health Dashboard. |

---

## Usage

### Static configuration (recommended)

Pass resource identifiers explicitly. Works for all 6 services.

```hcl
module "cloudwatch_alarms" {
  source  = "convops-io/cloudwatch-alarms/aws"
  version = "~> 0.1"

  # RDS
  rds_instance_identifiers  = ["prod-db", "prod-replica"]
  rds_connections_threshold = 150 # override to 80% of your instance's max_connections

  # Lambda
  lambda_function_names = ["api-handler", "worker"]
  lambda_timeouts = {
    "api-handler" = 30000  # 30s timeout in ms
    "worker"      = 900000 # 15min timeout in ms
  }

  # ECS
  ecs_cluster_name  = "prod-cluster"
  ecs_service_names = ["api", "worker"]
  ecs_running_task_min_count = {
    "api"    = 2
    "worker" = 1
  }

  # ALB — get suffix from: aws elbv2 describe-load-balancers
  alb_arn_suffixes = ["app/prod-alb/0123456789abcdef"]

  # EC2
  ec2_instance_ids = ["i-0abc123def456789a"]

  # DynamoDB
  dynamodb_table_names                      = ["users", "sessions"]
  dynamodb_consumed_read_capacity_threshold = 800 # set to 80% of provisioned RCU
}
```

### With SNS notifications

```hcl
module "cloudwatch_alarms" {
  source  = "convops-io/cloudwatch-alarms/aws"
  version = "~> 0.1"

  rds_instance_identifiers = ["prod-db"]
  # ... other resources ...

  alarm_actions = ["arn:aws:sns:us-east-1:123456789012:my-alerts"]
  ok_actions    = ["arn:aws:sns:us-east-1:123456789012:my-alerts"]
}
```

### Auto-discovery

Automatically discovers resources in your AWS account. Use tag filters to scope to production only.

> ⚠️ **Auto-discovery support varies by service:**
> - RDS ✅ Full support (filter by tags)
> - EC2 ✅ Full support (filter by tags)
> - ALB ✅ Full support (filter by tags)
> - ECS ✅ Services discovered via Resource Groups Tagging API, filtered by cluster name and optional tags
> - Lambda ⚠️ No native list data source — use static config
> - DynamoDB ⚠️ No native list data source — use static config

```hcl
module "cloudwatch_alarms" {
  source        = "convops-io/cloudwatch-alarms/aws"
  version       = "~> 0.1"
  auto_discover = true

  ec2_filter_tags = { Environment = "prod" }
  rds_filter_tags = { Environment = "prod" }
  alb_filter_tags = { Environment = "prod" }

  # ECS still needs cluster and service names
  ecs_auto_discover_cluster_name = "prod-cluster"
  ecs_service_names              = ["api", "worker"]

  # Lambda and DynamoDB — static config only
  lambda_function_names = ["api-handler"]
  dynamodb_table_names  = ["users"]
}
```

### ConvOps integration (optional)

When an alarm fires, engineers see a link to automated root cause analysis directly in the CloudWatch alarm description.

```hcl
module "cloudwatch_alarms" {
  source  = "convops-io/cloudwatch-alarms/aws"
  version = "~> 0.1"

  rds_instance_identifiers = ["prod-db"]
  # ... other resources ...

  enable_convops = true
  # Appends to every alarm description:
  # "Diagnosed by ConvOps — connect your AWS account at convops.io/audit"
}
```

---

## Overriding thresholds

Every threshold is a variable. Override only what you need — the rest use the proven defaults.

```hcl
module "cloudwatch_alarms" {
  source  = "convops-io/cloudwatch-alarms/aws"
  version = "~> 0.1"

  rds_instance_identifiers   = ["prod-db"]
  rds_cpu_threshold          = 70  # more sensitive than default 80
  rds_connections_threshold  = 400 # db.r5.xlarge: max_connections ~500, alarm at 80%

  lambda_function_names      = ["api-handler"]
  lambda_error_threshold     = 5   # tolerate up to 5 errors before alarming
}
```

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws provider | >= 5.0.0 |

---

## IAM permissions required

Always required:
- `cloudwatch:PutMetricAlarm`
- `cloudwatch:DeleteAlarms`
- `cloudwatch:DescribeAlarms` (Terraform refresh)

Required for auto-discovery (`auto_discover = true`):
- `tag:GetResources` — ECS service discovery via Resource Groups Tagging API
- `rds:DescribeDBInstances` — RDS instance discovery
- `ec2:DescribeInstances` — EC2 instance discovery
- `elasticloadbalancing:DescribeLoadBalancers` — ALB discovery
- `ecs:DescribeClusters` — ECS cluster lookup

---

## Contributing

Issues and PRs welcome. When adding a new alarm, include:
1. The metric name and namespace
2. The recommended threshold and why
3. What `treat_missing_data` should be set to and why

---

## What happens after the alarm fires?

This module creates the alarms. When they fire, you still need to investigate — check logs, metrics, recent deploys, resource state.

[ConvOps](https://convops.io/audit) automates that investigation. When an alarm fires, ConvOps reads CloudWatch Logs, CloudTrail, resource state, and service health to deliver a plain-English root cause to WhatsApp or Slack in under 60 seconds. Free for 1 AWS account.

---

## License

Apache 2.0 — see [LICENSE](LICENSE).

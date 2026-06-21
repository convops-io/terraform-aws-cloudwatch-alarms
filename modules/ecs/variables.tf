variable "cluster_name" {
  type    = string
  default = ""
}
variable "service_names" {
  type    = list(string)
  default = []
}
variable "auto_discover" {
  type    = bool
  default = false
}
variable "filter_tags" {
  description = "Tag filters for ECS auto-discovery. Example: { Environment = \"prod\" }"
  type        = map(string)
  default     = {}
}
variable "cpu_threshold" {
  type    = number
  default = 80
}
variable "memory_threshold" {
  type    = number
  default = 85
}
variable "running_task_min_count" {
  description = "Map of service name to minimum running task count."
  type        = map(number)
  default     = {}
}
variable "alarm_actions" {
  type    = list(string)
  default = []
}
variable "ok_actions" {
  type    = list(string)
  default = []
}
variable "insufficient_data_actions" {
  type    = list(string)
  default = []
}
variable "convops_suffix" {
  type    = string
  default = ""
}
variable "tags" {
  type    = map(string)
  default = {}
}

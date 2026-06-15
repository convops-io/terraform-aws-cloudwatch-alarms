variable "function_names" {
  type    = list(string)
  default = []
}
variable "error_threshold" {
  type    = number
  default = 0
}
variable "throttle_threshold" {
  type    = number
  default = 0
}
variable "duration_percent_threshold" {
  type    = number
  default = 80
}
variable "concurrent_executions_threshold" {
  type    = number
  default = 800
}
variable "function_timeouts" {
  description = "Map of function name to timeout in milliseconds."
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

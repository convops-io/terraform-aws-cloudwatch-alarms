variable "arn_suffixes" {
  type    = list(string)
  default = []
}
variable "auto_discover" {
  type    = bool
  default = false
}
variable "filter_tags" {
  type    = map(string)
  default = {}
}
variable "five_xx_threshold" {
  type    = number
  default = 10
}
variable "response_time_threshold" {
  type    = number
  default = 2
}
variable "unhealthy_host_threshold" {
  type    = number
  default = 0
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

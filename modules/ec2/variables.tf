variable "instance_ids" {
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
variable "cpu_threshold" {
  type    = number
  default = 85
}
variable "network_in_min_threshold" {
  type    = number
  default = 1000
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

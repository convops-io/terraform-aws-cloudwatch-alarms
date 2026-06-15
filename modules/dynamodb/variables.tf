variable "table_names" {
  type    = list(string)
  default = []
}
variable "throttle_threshold" {
  type    = number
  default = 0
}
variable "consumed_read_capacity_threshold" {
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

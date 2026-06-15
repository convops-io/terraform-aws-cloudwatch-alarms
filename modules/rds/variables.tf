variable "instance_identifiers" {
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
  default = 80
}
variable "connections_threshold" {
  type    = number
  default = 100
}
variable "free_storage_threshold" {
  type    = number
  default = 10000000000
}
variable "freeable_memory_threshold" {
  type    = number
  default = 268435456
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

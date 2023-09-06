variable "prefix" {
   type        = string
  default     = "eHH"
  description = "The prefix which should be used for all resources in this example"
}

variable "resource_group_location" {
  type        = string
  default     = "Germany West Central"
  description = "Location for all resources."
}
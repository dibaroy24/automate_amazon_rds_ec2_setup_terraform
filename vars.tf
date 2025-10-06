variable "location" {
  description = "The location where resources are created"
  default     = "us-west-2"
}

variable "prefix" {
  description = "The value of the prefix will be used in naming of all resources in this exercise"
  default = "fiverr20251005"
}

variable "admin_password" {
    description = "Default password for admin"
}


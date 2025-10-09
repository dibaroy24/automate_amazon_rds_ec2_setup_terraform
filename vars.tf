variable "location" {
  description = "The location where resources are created"
  default     = "us-east-1"
}

variable "prefix" {
  description = "The value of the prefix will be used in naming of all resources in this exercise"
  default = "fiverr20251005"
}

variable "admin_user" {
  description = "Default admin user of the database"
  default = "cmpunk"
}

variable "admin_password" {
    description = "Default password for admin user"
}

variable "new_db" {
  description = "The name of the database that would be created"
  default = "latinoheat"
}

# variable "access_key" {}
# variable "secret_key" {}


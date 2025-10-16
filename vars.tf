variable "location" {
  description = "The location where resources are created"
  default     = "us-east-1"
}

variable "prefix" {
  description = "The value of the prefix will be used in naming of all resources in this exercise"
  default = "fiverr20251005"
}

variable "db_username" {
  description = "Default admin user of the database"
  default = "cmpunk"
}

variable "db_password" {
    description = "Default password for database admin user"
}

variable "main_db" {
  description = "The name of the database that would be created"
  default = "latinoheat"
}

variable "public_key_path" {
  description = "Path to the public key file for the EC2 key pair"
  type        = string
  default     = "~/.ssh/my_tfkey.pub" # Example default path
}

/*
variable "private_key_path" {
  description = "Path to the private key file for the EC2 key pair"
  type        = string
  default     = "~/.ssh/my_tfkey" # Example default path
}
*/

# variable "access_key" {}
# variable "secret_key" {}


#######################################################################
## Required Variables                                                ##
#######################################################################

variable "name" {
  description = "Name of the created VPC.  Created resources will be prefixed with this string."
}

variable "cidr" {
  description = "CIDR range for created VPC."
}

variable "mgmt_subnet" {
  description = "Management subnet address range."
}

variable "public_subnet" {
  description = "Public subnet address range."
}

variable "web_subnet" {
  description = "Web subnet address range."
}

variable "db_subnet" {
  description = "DB subnet address range."
}

#######################################################################
## Optional Variables                                                ##
#######################################################################

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

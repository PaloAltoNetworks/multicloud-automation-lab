#######################################################################
## Required Variables                                                ##
#######################################################################

variable "name" {
  description = "Name of the created VPC.  Created resources will be prefixed with this string."
}

variable "cidr" {
  description = "CIDR range for created VPC."
}

variable "azs" {
  description = "Availability zones for created subnets."
  type        = "list"
}

variable "mgmt_subnets" {
  description = "Management subnets.  Will be created across the specified availability zones."
  type        = "list"
}

variable "public_subnets" {
  description = "Public subnets.  Will be created across the specified availability zones."
  type        = "list"
}

variable "web_subnets" {
  description = "Web subnets.  Will be created across the specified availability zones."
  type        = "list"
}

variable "db_subnets" {
  description = "DB subnets.  Will be created across the specified availability zones."
  type        = "list"
}

#######################################################################
## Optional Variables                                                ##
#######################################################################

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

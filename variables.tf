variable "region" {
  description = "Value of the aws region to deploy the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "Value of the aws account id"
  type        = number
  default     = 577247986912
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ultimate"
}

variable "workspace" {
  description = "Value of the workspace that the infrastructure will be deployed to"
  type        = string
  default     = "develop"
}

variable "db_username" {
  description = "Username of the rds database that will be used"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Password of the rds database that will be used"
  type        = string
  default     = "postgres"
}

variable "db_name" {
  description = "Name of the main database in the rds postgres instance that will be used"
  type        = string
  default     = "yelp"
}

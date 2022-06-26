variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS Region"
}

variable "resource_tag" {
  type = map
  description = "Resource tag for the project"
  default = {
    
  }
}

variable "force_destroy_state" {
  default = true
  type = bool
  description = "Force destroy the s3 bucket containing state files?"
}

variable "project_name" {
  type = string
  default = "tf-s3-backend"
  description = "The project name"
}

variable "principal_arns" {
  type = list(string)
  default = null
  description = "Principal arns that can access the s3 state buckets"
}


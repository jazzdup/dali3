variable "project" {
  type    = string
  default = "dali3-385220"
}

variable "region" {
  type        = string
  description = "to deploy to"
  default     = "europe-west2"
}

variable "replica_region" {
  type        = string
  description = "to replicate to"
  default     = "europe-west1"
}

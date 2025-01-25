variable "project_id" {
  type        = string
  description = "The GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region to use"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Compute Engine zone to use"
  default     = "us-central1-a"
}

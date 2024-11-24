# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


# Put the comments in the description field

# GCP project
variable "target_gcp_project_id" {
  type    = string
}


# GCP region
variable "target_gcp_region" {
  type    = string
  default = "us-central1"
}


# namespace/prefix
variable "povstorm_namespace" {
  type    = string
  default = "my-povstorm"
}


# how many instances to allow
variable "cloudrun_instances" {
  type    = integer
  default = 100
}


# render container tag
variable "render_service_container_tag" {
  type    = string
}


# render service CPUs
variable "render_service_cpus" {
  type    = string
  default = "1"
}


# render service CPUs
variable "render_service_ram" {
  type    = string
  default = "1024Mi"
}


# render service timeout
variable "render_service_timeout" {
  type    = string
  default = "3600s"  # this is the maximum allow runtime for cloud run, ie., each from must render within an hour
}

render_service_max_instance_count


# render service maximum number of instances
variable "render_service_max_instance_count" {
  type    = integer
  default = 100  
}


# stitch service container tag
variable "stitch_service_docker_tag" {
  type    = string
}



variable "render_service_docker_tag" {
  description = "The docker tag of the render service container."
  type    = string
}

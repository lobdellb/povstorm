# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------


variable "target_gcp_project_id" {
  description = "GCP project where all resources are spawned."
  type    = string
}


variable "target_gcp_region" {
  description = "GCP region where all resources are spawned."
  type    = string
  default = "us-central1"
}


variable "povstorm_namespace" {
  description = "All GCP resource IDs are prefixed with this string."
  type    = string
  default = "my-povstorm"
}


variable "render_service_cpus" {
  description = "The number of CPUs afforded to the render service."
  type    = string
  default = "1000m"
}


variable "render_service_ram" {
  description = "The amount of RAM afforded to the render service."
  type    = string
  default = "1024Mi"
}



variable "render_service_timeout" {
  description = "Request timeout for the render service."
  type    = string
  default = "3600s"  # this is the maximum allow runtime for cloud run, ie., each from must render within an hour
}



variable "render_service_max_instance_count" {
  description = "The number of Cloud Run instances which will be used to render the frames. The more instances the faster the images will be rendered."
  type    = number
  default = 100  
}


variable "stitch_service_docker_tag_postfix" {
  description = "The docker tag of the stitch service container."
  type    = string
}


variable "render_service_docker_tag_postfix" {
  description = "The docker tag of the render service container. The full docker tag is this prefixed with the povstorm_namespace TF variable."
  type    = string
}

variable "user_labels" {
  description = "Any GCP labels the user wishes to apply to all created resources."
  type = map(string)
  default = {}

  
}

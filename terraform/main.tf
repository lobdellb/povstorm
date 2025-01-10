

module "povstorm" {
   source = "../terraform_module/"

   target_gcp_project_id = var.target_gcp_project_id

   target_gcp_region = var.target_gcp_region

   povstorm_namespace = var.povstorm_namespace

   render_service_cpus = var.render_service_cpus

   render_service_ram = var.render_service_ram

   render_service_timeout = var.render_service_timeout

   render_service_max_instance_count = var.render_service_max_instance_count 

   stitch_service_docker_tag_postfix = var.stitch_service_docker_tag_postfix

   render_service_docker_tag_postfix = var.render_service_docker_tag_postfix

   user_labels = var.user_labels

}



# variable "target_gcp_project_id" {
# variable "target_gcp_region" {
# variable "povstorm_namespace" {
# variable "render_service_cpus" {
# variable "render_service_ram" {
# variable "render_service_timeout" {
# variable "render_service_max_instance_count" {
# variable "stitch_service_docker_tag_postfix" {
# variable "render_service_docker_tag_postfix" {
# variable "user_labels" {





# I need to see some settings on this 

# resource "google_cloud_run_v2_service" "existing_service" {
#   name     = "povray-runner"
#   project = var.target_gcp_project_id
#   location = var.target_gcp_region

#   template {
   
#   }

# }
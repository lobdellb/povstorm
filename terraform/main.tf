

module "povstorm" {
   source = "../terraform_module/"

   target_gcp_project_id = var.target_gcp_project_id

   povstorm_namespace = var.povstorm_namespace

   render_service_max_instance_count = var.render_service_max_instance_count 

   stitch_service_docker_tag = var.stitch_service_docker_tag

   render_service_docker_tag = var.render_service_docker_tag

   user_labels = var.user_labels

}



# I need to see some settings on this 

# resource "google_cloud_run_v2_service" "existing_service" {
#   name     = "povray-runner"
#   project = var.target_gcp_project_id
#   location = var.target_gcp_region

#   template {
   
#   }

# }
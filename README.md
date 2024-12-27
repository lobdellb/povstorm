
# 


## Todo

- Add a container for combining the videos.
- Figure out a way to fail if one frame fails. Figure out a way to kick-off the stitch phase.
- Figure out how to make sure all frames were processed before combining.
- Surface some error messages and progress logging.
- Write howto / docs
- Write the Makefile
- Add tests, linting, blacking for python




# Pieces

- A container which renders images.
- A container which loads all the images into a single video.
- A terraform module which stands up the GCP infrastructure.
- A driver program (client) to run locally which generates string of images.
- Tests 
- Makefile for building, deploying, testing. 






# povstorm
Render POVRAY SDL to  images, then video in GCP Cloud Run.




# Piece of the terraform module and their exposed paramters

* google_pubsub_topic - inbound
    * povstorm_namespace
* google_pubsub_topic - outbound
    * povstorm_namespace
* google_cloud_run_v2_service - render
    * povstorm_namespace
    * target_gcp_project_id
    * target_gcp_region
    * render_service_max_instance_count
    * render_service_cpus
    * render_service_ram
* google_storage_bucket - work bucket
    * povstorm_namespace
    * target_gcp_project_id
    * target_gcp_region
* google_service_account - service(s) identity
    * povstorm_namespace
    * target_gcp_project_id
    * povstorm_namespace
* google_storage_bucket_iam_member - bucket access
* google_project_iam_member - services identity roles
    * target_gcp_project_id
* google_artifact_registry_repository 
    * target_gcp_region
    * target_gcp_project_id
    * povstorm_namespace
* google_eventarc_trigger
    * povstorm_namespace
    * target_gcp_project_id
    * target_gcp_region
* google_artifact_registry_docker_image
    * target_gcp_region
    * 

  location      = var.target_gcp_region
  repository_id = google_artifact_registry_repository.container_registry.repository_id
  image_name = var.render_service_docker_tag
  project = var.target_gcp_project_id


for the artifact registery I need

* var.target_gcp_region
* repository_id
* project = var.target_gcp_project_id
* image_name 



*google_artifact_registry_docker_image
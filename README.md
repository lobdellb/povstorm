
# povstorm

When I was a kid exploring the wonderful land of "Electronic Bullitin Boards" (BBSs) I found a raytracing program called POVRAY which consumed a computer code-like description of a scene composed of cameras, light sources, shape primatives, textures, and so-on which it would convert to an image.  I recently re-discovered this tool and started to play with it again, quite enjoyably.  When I first used POVRAY it would take a day or more to render what was then a high-resolution image (640x480 pixels), but now images ten times as large can be done in seconds or minutes so I thought "wouldn't it be fun to render some videos" which again take a bit of time for a video of a few thousand frames or a duration of a few minutes.  Before long I thought "I could iterate a lot faster if I would render the frames of the video concurrently in the cloud. The repository contains the code and tooling I've used to automate that process.

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




# To run this you need

* Python 3.12 (will probably work on other versions, but needs tested).
* Docker
* `jq`
* gnu Make
* terraform


# How to configure and use

* Set up your python enviornment 
* Install docker
* Edit `./terraform/blobdell-povstorm.tfvars`
* run `make ...` to stand up the infra, build containers, etc.
* edit or copy the contents of `./example_client/` to do your bidding
* run `python ./example_client/run.py`
* collect the result images and/or video from GCS
* take down the infrastructure with `make terraform_destory`


# List of files which are created in the local filesystem and what they do.

* Python envs
* env 
* TF files (plan and output)
* The whl file for the client.
* latest_render_container_hash
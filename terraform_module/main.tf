# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------


# Todo: 
# - labels
# - add linter

# Locals
locals {
  service_sa_iam_roles = [ "roles/logging.logWriter"]

  default_labels = {
    application  = var.povstorm_namespace
  }

  all_labels = merge( var.user_labels , local.default_labels )

  render_service_image_name = "${var.target_gcp_region}-docker.pkg.dev/${var.target_gcp_project_id}/${var.povstorm_namespace}-repository/${var.render_service_docker_tag_postfix}"

  mount_name = "work-bucket"

  render_service_tag = formatdate("YYYYMMDDhhmmdd")

  render_service_image_name_and_tag = "${local.render_service_image_name}:${local.render_service_tag}"
}



# PubSub for inbound render requests

resource "google_pubsub_topic" "inbound_topic" {
  name = "${var.povstorm_namespace}-inbound-topic"
  project = var.target_gcp_project_id

  labels = local.all_labels

  message_retention_duration = "86600s"  # Is this an okay default?
}



# PubSub for images which have been rendered

resource "google_pubsub_topic" "outbound_topic" {
  name = "${var.povstorm_namespace}-outbound-topic"
  project = var.target_gcp_project_id

  labels = local.all_labels

  message_retention_duration = "86600s"  # Is this an okay default?
}







# Cloud run service for rendering

resource "google_cloud_run_v2_service" "render_service" {
  name     = "${var.povstorm_namespace}-render-service"
  project = var.target_gcp_project_id
  location = var.target_gcp_region
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"



  template {

    service_account = google_service_account.services_identity.email 

    scaling {
      max_instance_count = var.render_service_max_instance_count
      min_instance_count = 0
    }

    max_instance_request_concurrency = 2 # default to 80. Might be faster with 1 or 4, not sure.

    containers {
      image = local.render_service_image_name
      resources {
        limits = {
          cpu    = var.render_service_cpus
          memory = var.render_service_ram
        }

        startup_cpu_boost = true
        cpu_idle = true # Shut down all containers when not runnings

      }

      # ports {
      #   container_port = 8080
      # }
      env {
        name = "MOUNT_PATH"
        value = "/mnt/${local.mount_name}"
      }

      env {
        name = "GCP_PROJECT" 
        value = var.target_gcp_project_id
      }

      volume_mounts {
        name       = local.mount_name
        mount_path = "/mnt/${local.mount_name}"
      }

    }

    timeout = var.render_service_timeout

    volumes {
      name = local.mount_name
      gcs {
        bucket    = google_storage_bucket.work_bucket.name
        read_only = false
      }
    }

  }

  labels = local.all_labels

  depends_on = [ null_resource.push_render_container_image ]

}


# Cloud Run service for stiching the frames together
# resource "google_cloud_run_v2_service" "stich_service" {
#   name     = "cloudrun-service"
#   location = "us-central1"
#   deletion_protection = false
#   ingress = "INGRESS_TRAFFIC_ALL"

#   template {
#     containers {
#       image = "us-docker.pkg.dev/cloudrun/container/hello"
#       resources {
#         limits = {
#           cpu    = "2"
#           memory = "1024Mi"
#         }
#       }
#     }
#   }
# }



# Cloud Storage bucket for parking the still frames and output video

resource "google_storage_bucket" "work_bucket" {

  name          = "${var.povstorm_namespace}-work"
  project = var.target_gcp_project_id
  location      = var.target_gcp_region
  storage_class = "REGIONAL"
  force_destroy = true

  uniform_bucket_level_access = true

  versioning {
    enabled = true  # This is so we can use a gcs file as a distributed lock.
  }

  labels = local.all_labels

  # This seems to come with soft delete enabled. I tried changing the soft delete setting in the console
  # and terraform didn't seem to notice something had changed so "soft delete" may not be supported by
  # Terraform just yet. The default retention before actual deletion is 7 days which is reasonable. 

}


# Identity for the cloud run 

resource "google_service_account" "services_identity" {
  account_id   = "${var.povstorm_namespace}-service-sa"
  project = var.target_gcp_project_id
  display_name = "${var.povstorm_namespace} - service identity"

}



# Access for the Cloud Run SA
# r/w on the bucket

resource "google_storage_bucket_iam_member" "services_identity_permissions" {

  bucket = google_storage_bucket.work_bucket.name
  role = "roles/storage.objectUser"

  member = "serviceAccount:${google_service_account.services_identity.email}"
}




resource "google_project_iam_member" "project_service_identy_access" {

  for_each = toset(local.service_sa_iam_roles)

  project = var.target_gcp_project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.services_identity.email}"
}






# Place to put the container images.

resource "google_artifact_registry_repository" "container_registry" {
  location      = var.target_gcp_region
  project = var.target_gcp_project_id
  repository_id = "${var.povstorm_namespace}-repository"
  description   = "${var.povstorm_namespace}-Repository for the render and stitch service containers."
  format        = "DOCKER"

  labels = local.all_labels
}



# EventArc trigger for the Cloud Run service

resource "google_eventarc_trigger" "inbound_trigger" {
    name = "${var.povstorm_namespace}-trigger"
    project = var.target_gcp_project_id
    location = var.target_gcp_region

    matching_criteria {
        attribute = "type"
        value = "google.cloud.pubsub.topic.v1.messagePublished"
    }

    destination {
        cloud_run_service {
            service = google_cloud_run_v2_service.render_service.name
            region = var.target_gcp_region
            path = "/process_workunit"
        }
    }
    labels = local.all_labels
}



data "terraform_local_file" "my_file" {
  filename = "../latest_render_container_hash" 
}




# will need:  gcloud auth configure-docker us-central1-docker.pkg.dev
resource "null_resource" "push_render_container_image" {

  # must already be done by the person running terraform apply: gcloud auth configure-docker us-central1-docker.pkg.dev &&
  # docker build -t us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.my_repo.name}/my-image:tag . &&
  # docker push us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.my_repo.name}/my-image:tag

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {

    command = <<EOT
docker push ${local.render_service_image_name} ${local.render_service_image_name_and_tag}
EOT
  }

  depends_on = [ google_artifact_registry_repository.container_registry ]
}



# I don't think we need this:

# $${TF_VAR_target_gcp_region}-docker.pkg.dev/$${TF_VAR_target_gcp_project_id}/$${TF_VAR_render_service_docker_tag_postfix}:latest 
# data "google_artifact_registry_docker_image" "push_render_container_image" {
#   location      = var.target_gcp_region
#   repository_id = google_artifact_registry_repository.container_registry.repository_id
#   image_name = var.render_service_docker_tag
#   project = var.target_gcp_project_id
#   # depends_on = [ null_resource.push_render_container_image ]
# }









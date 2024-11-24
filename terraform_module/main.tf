# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------


# Todo: 
# - labels
# - add linter
# - set the resource names to be unique
# - add project to every resource


# Locals
locals {
  service_sa_iam_roles = [ "role/logging.logWriter"]
}

# PubSub for inbound render requests

resource "google_pubsub_topic" "inbound_topic" {
  name = "${var.povstorm_namespace}-inbound-topic"

  labels = {
    foo = "bar"
  }

  message_retention_duration = "86600s"  # Is this an okay default?
}



# PubSub for images which have been rendered

resource "google_pubsub_topic" "outbound_topic" {
  name = "${var.povstorm_namespace}-outbound-topic"

  labels = {
    foo = "bar"
  }

  message_retention_duration = "86600s"  # Is this an okay default?
}







# Cloud run service for rendering

resource "google_cloud_run_v2_service" "render_service" {
  name     = "${var.povstorm_namespace}-render-service"
  location = var.target_gcp_region
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {

    scaling {
      max_instance_count = var.render_service_max_instance_count
    }

    containers {
      image = var.render_service_docker_tag
      resources {
        limits = {
          cpu    = var.render_service_cpus
          memory = var.render_service_ram
        }

        startup_cpu_boost = true

      }

      # ports {
      #   container_port = 8080
      # }
    }


    timeout = var.render_service_timeout

    volumes {
      name = "work-bucket"
      gcs {
        bucket    = google_storage_bucket.work_bucket.name
        read_only = false
      }
    }

  }
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
  location      = var.target_gcp_region
  storage_class = "REGIONAL"
  force_destroy = false

  uniform_bucket_level_access = true

}


# Identity for the cloud run 

resource "google_service_account" "services_identity" {
  account_id   = "${var.povstorm_namespace}-service-sa"
  display_name = "${var.povstorm_namespace} - service identity"
}



# Access for the Cloud Run SA
# r/w on the bucket

resource "google_storage_bucket_iam_member" "services_identity_permissions" {

  bucket = google_storage_bucket.work_bucket.name
  role = "roles/storage.objectUser"

  member = "serviceAccount:${google_service_account.services_identity.email}"
}




resource "google_project_iam_member" "project" {

  for_each = set()

  project = var.target_gcp_project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.services_identity.email}"
}






# Place to put the container images.

resource "google_artifact_registry_repository" "container_registry" {
  location      = "us-central1"
  repository_id = "my-repository"
  description   = "example docker repository"
  format        = "DOCKER"
}



# EventArc trigger for the Cloud Run service

resource "google_eventarc_trigger" "inbound_trigger" {
    name = "${var.povstorm_namespace}-trigger"
    location = var.target_gcp_region

    matching_criteria {
        attribute = "type"
        value = "google.cloud.pubsub.topic.v1.messagePublished"
    }

    destination {
        cloud_run_service {
            service = google_cloud_run_service.default.name
            region = var.target_gcp_region
        }
    }
    labels = {
        foo = "bar"
    }
}



# resource "null_resource" "push_render_container_image" {
#   provisioner "local-exec" {
#     command = <<EOT
#     gcloud auth configure-docker us-central1-docker.pkg.dev &&
#     docker build -t us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.my_repo.name}/my-image:tag . &&
#     docker push us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.my_repo.name}/my-image:tag
#     EOT
#   }
# }
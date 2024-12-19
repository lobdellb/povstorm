


# output "render_container_image_name" {
#   description = "The fully qualified name of the render image once it's uploaded to artifact registry."
#   value = data.google_artifact_registry_docker_image.push_render_container_image.name
# }


output "repository_id" {
  value = google_artifact_registry_repository.container_registry.repository_id
}


# output "render_container_tags" {
#   value = data.google_artifact_registry_docker_image.push_render_container_image.tags
# }


# output "render_container_self_link" {
#   value = data.google_artifact_registry_docker_image.push_render_container_image.self_link
# }


output "render_service_image_name" {
  value = local.render_service_image_name
}


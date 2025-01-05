
# output "render_container_constructed_name" {
#   value = module.povstorm.render_container_constructed_name
# }


output "repository_id" {
  value = module.povstorm.repository_id
}


# output "render_container_tags" {
#   value = module.povstorm.render_container_tags
# }

# output "render_container_self_link" {
#   value = module.povstorm.render_container_self_link
# }

output "render_service_image_name" {
  value = module.povstorm.render_service_image_name
}

output "inbound_topic_id" {
  value = module.povstorm.inbound_topic_id
}

output "work_bucket_name" {
  value = module.povstorm.work_bucket_name
}




# Outputs I need to configure the cluster object
# - The name of the bucket.
# - Inbound topic ID


terraform {
  
  required_version = ">= 0.14"  # Do I need to test that this works with all verions, or leave this for the most recent version?

  "google" = {

    source = "hashicorp/google"
    version = "~> 3.0"

  }

}


provider "google" {
  project     = var.target_gcp_project_id
  region      = var.target_gcp_region
}
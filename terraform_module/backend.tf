

terraform {
  
  required_version = ">= 1.9.8"  


  required_providers {

    google = {

      source = "hashicorp/google"
      version = "~> 6.12"

    }

  }

}


provider "google" {
  project     = var.target_gcp_project_id
  region      = var.target_gcp_region
}
terraform {
  backend "gcs" {
    bucket = "dali3-385220-terraform-state"
    prefix = "dali-poo"
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

data "google_project" "current" {
  provider = google
}

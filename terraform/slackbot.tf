resource "google_compute_region_instance_group_manager" "slackbot" {
  name   = "dali-poo"
  region = var.region

  base_instance_name = "dali-poo"

  target_size = 1

  version {
    instance_template = google_compute_instance_template.slackbot.id
  }

  update_policy {
    type                           = "PROACTIVE"
    minimal_action                 = "RESTART"
    most_disruptive_allowed_action = "REPLACE"
    replacement_method             = "SUBSTITUTE"
    max_surge_fixed                = length(data.google_compute_zones.region.names) + 1
    max_unavailable_fixed          = length(data.google_compute_zones.region.names)
  }
}

data "google_compute_zones" "region" {
  region = var.region
}

resource "google_compute_instance_template" "slackbot" {
  name_prefix = "dali-poo"
  description = "images with dall-e"

  instance_description = "dali-poo"
  machine_type         = "e2-micro"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = false
    preemptible         = true
    on_host_maintenance = "TERMINATE"
  }

  disk {
    source_image = "cos-cloud/cos-101-lts"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"

    access_config {
    }
  }

  metadata = {
    "user-data"                 = file("user-data.yaml")
    "google-monitoring-enabled" = "true"
  }

  service_account {
    email  = google_service_account.slackbot.email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_service_account" "slackbot" {
  display_name = "dali poo"
  account_id   = "dali-poo"
  project      = data.google_project.current.project_id
}

resource "google_project_iam_member" "slackbot" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/monitoring.metricWriter",
    "roles/logging.logWriter",
  ])
  project = data.google_project.current.project_id
  member  = format("serviceAccount:%s", google_service_account.slackbot.email)
  role    = each.value
}

resource "google_secret_manager_secret" "slackbot" {
  for_each = toset([
   "dali-poo-bot-token",
    "dali-poo-app-token",
    "dali-poo-signing-secret",
  ])
  secret_id = each.value
  replication {
    user_managed {
      replicas {
        location = var.region
      }
      replicas {
        location = var.replica_region
      }
    }
  }
}

resource "google_secret_manager_secret_iam_member" "slackbot" {
  for_each  = google_secret_manager_secret.slackbot
  member    = format("serviceAccount:%s", google_service_account.slackbot.email)
  role      = "roles/secretmanager.secretAccessor"
  secret_id = each.value.secret_id
}
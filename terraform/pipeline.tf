resource "google_sourcerepo_repository" "slackbot" {
  name = "dali-poo"
}

resource "google_cloudbuild_trigger" "build" {
  name = "build-dali-poo"
  trigger_template {
    repo_name   = google_sourcerepo_repository.slackbot.name
    branch_name = "master"
  }

  ignored_files = ["terraform/**"]

  filename = "cloudbuild/build.yaml"
  project  = data.google_project.current.project_id
  provider = google
}


resource "google_cloudbuild_trigger" "deploy" {
  name = "deploy-dali-poo"
  trigger_template {
    repo_name   = google_sourcerepo_repository.slackbot.name
    branch_name = "master"
  }

  included_files = ["terraform/**"]

  filename = "cloudbuild/deploy.yaml"
  project  = data.google_project.current.project_id
  provider = google
}

resource "google_project_iam_member" "cloudbuild" {
  for_each = toset([
    "roles/owner",
    "roles/storage.objectCreator",
    "roles/storage.objectViewer"
  ])
  role    = each.value
  member  = "serviceAccount:${data.google_project.current.number}@cloudbuild.gserviceaccount.com"
  project = data.google_project.current.project_id
}

resource "google_artifact_registry_repository" "slackbot" {
  location      = "europe"
  repository_id = "dali-poo"
  description   = "images with dall-e"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "readers" {
  for_each   = {
     slackbot = format("serviceAccount:%s", google_service_account.slackbot.email)
  }
  role       = "roles/artifactregistry.reader"
  project    = google_artifact_registry_repository.slackbot.project
  location   = google_artifact_registry_repository.slackbot.location
  repository = google_artifact_registry_repository.slackbot.name
  member     = each.value
}
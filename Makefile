TERRAFORM_STATE_BUCKET=dali3-385220-terraform-state
TERRAFORM_STATE_BUCKET_LOCATION=eu
GOOGLE_PROJECT=dali3-385220
GOOGLE_REGION=europe-west2
SLACKBOT_NAME=dali-poo

GOOGLE_PROJECT_SERVICES= \
    cloud.googleapis.com \
    compute.googleapis.com \
    sourcerepo.googleapis.com \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com \
    secretmanager.googleapis.com

include Makefile.mk

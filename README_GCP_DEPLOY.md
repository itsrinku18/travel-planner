# Deploy Flutter Web on GCP (Cloud Run)

This project includes a `Dockerfile` (Flutter web build → Nginx) and a `cloudbuild.yaml` for automated deploys.

## Prerequisites

- Install Google Cloud SDK (`gcloud`) and Docker
- You must have a Google Cloud project and billing enabled
- You must be logged in:

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

## One-time setup

Enable APIs:

```bash
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com
```

Create an Artifact Registry repo:

```bash
gcloud artifacts repositories create travel-planner \
  --repository-format=docker \
  --location=asia-south1
```

## Deploy with Cloud Build (recommended)

Run:

```bash
gcloud builds submit --config cloudbuild.yaml
```

After deploy, get the URL:

```bash
gcloud run services describe travel-planner-web --region asia-south1 --format="value(status.url)"
```

## Grant access to a user (optional)

If you want the email `merinkukumar69@gmail.com` to manage the service:

```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="user:merinkukumar69@gmail.com" \
  --role="roles/run.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="user:merinkukumar69@gmail.com" \
  --role="roles/iam.serviceAccountUser"
```

If you want them to only view:

```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="user:merinkukumar69@gmail.com" \
  --role="roles/run.viewer"
```


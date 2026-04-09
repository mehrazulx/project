# Project

## Quick Runbook

1. Export the SMB password as an environment variable (do not store it in `terraform.tfvars`):
   `export TF_VAR_smb_password='your-strong-password'`
2. Ensure the backend lock table exists:
   `mys3-privatelink-tf-locks` in `us-east-2`.
3. Initialize Terraform:
   `make init`
4. Baseline rollout (ingestion disabled):
   `make plan` then `make apply`
5. S3-only rollout (no DataSync, good for local-folder testing):
   `make plan-s3-only` then `make apply-s3-only`
6. Full ingestion rollout:
   `make plan-ingestion` then `make apply-ingestion`

## RegAffairs Ingestion Design

This stack now includes Terraform scaffolding for a weekly ingestion path:

1. On-prem SMB (F-drive) -> AWS DataSync
2. DataSync -> S3 bucket (versioned + SSE-KMS)
3. DataSync success event -> EventBridge
4. EventBridge -> Step Functions
5. Step Functions -> `bedrock:StartIngestionJob` for the Bedrock Knowledge Base data source

## New Terraform Files

- `s3_ingestion.tf`: S3 bucket, KMS key, encryption, versioning, lifecycle, and bucket hardening.
- `datasync.tf`: SMB source location, S3 destination location, IAM access role, and weekly task.
- `eventbridge_ingestion.tf`: Success-event trigger and Step Functions workflow for Bedrock KB refresh.

## Enablement Flags

These are disabled by default so existing infra is not impacted.

```hcl
enable_regaffairs_ingestion = false
enable_regaffairs_datasync  = false
enable_bedrock_kb_sync      = false
```

Use these modes:

- S3-only mode (no DataSync): `enable_regaffairs_ingestion=true`, `enable_regaffairs_datasync=false`, `enable_bedrock_kb_sync=false`
- Full DataSync mode: `enable_regaffairs_ingestion=true`, `enable_regaffairs_datasync=true`
- Bedrock auto-sync mode: additionally set `enable_bedrock_kb_sync=true` (requires DataSync mode)

## Required Values Before Enabling

Update these values before enabling DataSync mode:

- `datasync_agent_arn`
- `smb_domain`
- `smb_server_hostname`
- `smb_subdirectory`
- `smb_user`
- `smb_password`
- `bedrock_knowledge_base_id` (if `enable_bedrock_kb_sync = true`)
- `bedrock_data_source_id` (if `enable_bedrock_kb_sync = true`)

Set `smb_password` using `TF_VAR_smb_password`.

## Make Targets

- `make fmt`: Format Terraform files.
- `make init`: Reconfigure and initialize backend/providers.
- `make validate`: Validate Terraform configuration.
- `make plan`: Plan with values from `terraform.tfvars`.
- `make apply`: Apply with values from `terraform.tfvars`.
- `make plan-ingestion`: Plan with ingestion and KB sync enabled.
- `make apply-ingestion`: Apply with ingestion and KB sync enabled.
- `make plan-s3-only`: Plan S3/KMS ingestion resources only (no DataSync, no KB auto-sync).
- `make apply-s3-only`: Apply S3/KMS ingestion resources only (no DataSync, no KB auto-sync).

## Suggested Weekly Schedule

Default schedule is Sunday 07:00 UTC (`cron(0 7 ? * SUN *)`).
Adjust `datasync_schedule_expression` if you need a different window.

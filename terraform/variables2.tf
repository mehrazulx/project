

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "hello-world-app"
}

variable "container_image" {
  description = "Docker image to run in the ECS cluster"
  type        = string
}

variable "enable_regaffairs_ingestion" {
  description = "Enable creation of S3 resources for Regulatory Affairs document ingestion."
  type        = bool
  default     = false
}

variable "enable_regaffairs_datasync" {
  description = "Enable DataSync resources for SMB/F-drive transfer into the RegAffairs S3 bucket."
  type        = bool
  default     = true
}

variable "enable_bedrock_kb_sync" {
  description = "Enable EventBridge and Step Functions resources to trigger Bedrock Knowledge Base sync after DataSync success."
  type        = bool
  default     = false

  validation {
    condition     = !var.enable_bedrock_kb_sync || var.enable_regaffairs_datasync
    error_message = "enable_bedrock_kb_sync requires enable_regaffairs_datasync=true because it is triggered by DataSync success events."
  }
}

variable "regaffairs_documents_bucket_name" {
  description = "Optional override for the Regulatory Affairs documents S3 bucket name."
  type        = string
  default     = null
}

variable "regaffairs_noncurrent_version_expiration_days" {
  description = "How long to retain non-current object versions in the documents bucket."
  type        = number
  default     = 90
}

variable "regaffairs_s3_prefix" {
  description = "Destination prefix in S3 for ingested F-drive content."
  type        = string
  default     = "/regaffairs/source=fdrive"
}

variable "datasync_agent_arn" {
  description = "ARN for the DataSync agent deployed on-prem."
  type        = string
  default     = "arn:aws:datasync:us-east-2:111111111111:agent/agent-REPLACE_ME"
}

variable "datasync_schedule_expression" {
  description = "Weekly schedule expression for DataSync task executions."
  type        = string
  default     = "cron(0 7 ? * SUN *)"
}

variable "datasync_include_filter" {
  description = "Simple include filter for DataSync task (e.g. /** for all files)."
  type        = string
  default     = "/**"
}

variable "smb_domain" {
  description = "AD domain for the SMB server hosting the F-drive share."
  type        = string
  default     = "CORP"
}

variable "smb_server_hostname" {
  description = "DNS name or IP for the SMB server hosting the F-drive share."
  type        = string
  default     = "fileserver.corp.local"
}

variable "smb_subdirectory" {
  description = "SMB share subdirectory to sync (for example /RegAffairs)."
  type        = string
  default     = "/RegAffairs"
}

variable "smb_user" {
  description = "SMB username used by DataSync to read from the F-drive share."
  type        = string
  default     = "svc_datasync"
}

variable "smb_password" {
  description = "SMB password used by DataSync to read from the F-drive share."
  type        = string
  sensitive   = true
  default     = null

  validation {
    # trimspace(null) errors; coalesce(null,"") fails (Terraform coalesce skips empty strings).
    condition = !(var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync) || (
      trimspace(var.smb_password != null ? var.smb_password : "") != ""
      && (var.smb_password != null ? var.smb_password : "") != "REPLACE_ME"
    )
    error_message = "Set smb_password to a non-placeholder value when RegAffairs DataSync is enabled."
  }
}

variable "smb_mount_version" {
  description = "SMB protocol version DataSync should use."
  type        = string
  default     = "SMB3"

  validation {
    condition     = contains(["AUTOMATIC", "SMB2", "SMB3", "SMB1"], var.smb_mount_version)
    error_message = "smb_mount_version must be one of AUTOMATIC, SMB1, SMB2, or SMB3."
  }
}

variable "bedrock_knowledge_base_id" {
  description = "Existing Bedrock Knowledge Base ID to refresh after DataSync success."
  type        = string
  default     = "KB_REPLACE_ME"
}

variable "bedrock_data_source_id" {
  description = "Existing Bedrock Knowledge Base data source ID associated with the S3 bucket."
  type        = string
  default     = "DS_REPLACE_ME"
}

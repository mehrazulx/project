aws_region      = "us-east-2"
project_name    = "hello-world-app"
container_image = "880147167393.dkr.ecr.us-east-2.amazonaws.com/hello-world-app"

# RegAffairs ingestion
enable_regaffairs_ingestion = false
enable_regaffairs_datasync  = false
enable_bedrock_kb_sync      = false

# Set these before enabling
datasync_agent_arn  = "arn:aws:datasync:us-east-2:880147167393:agent/agent-REPLACE_ME"
smb_domain          = "CORP"
smb_server_hostname = "fileserver.corp.local"
smb_subdirectory    = "/RegAffairs"
smb_user            = "svc_datasync"
# Do not store smb_password in tfvars. Set it via environment variable:
# export TF_VAR_smb_password='your-strong-password'
bedrock_knowledge_base_id = "KL2NSAUFDY"
bedrock_data_source_id    = "GMSXBNKOKE"

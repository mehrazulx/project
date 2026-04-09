
output "load_balancer_url" {
  description = "URL of the load balancer"
  value       = "http://${aws_lb.ECS_NLB.dns_name}"
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition"
  value       = aws_ecs_task_definition.app.arn
}


output "ecs_task_role_arn" {
  value = aws_iam_role.existing_ecs_role.arn
}

output "provider_service_name" {
  value = aws_vpc_endpoint_service.Endservice.service_name
}

output "regaffairs_documents_bucket_name" {
  description = "S3 bucket name for Regulatory Affairs documents."
  value       = var.enable_regaffairs_ingestion ? aws_s3_bucket.regaffairs_documents[0].bucket : null
}

output "regaffairs_documents_bucket_arn" {
  description = "S3 bucket ARN for Regulatory Affairs documents."
  value       = var.enable_regaffairs_ingestion ? aws_s3_bucket.regaffairs_documents[0].arn : null
}

output "datasync_task_arn" {
  description = "ARN of the weekly DataSync task from F-drive SMB share to S3."
  value       = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync ? aws_datasync_task.regaffairs_weekly[0].arn : null
}

output "kb_refresh_state_machine_arn" {
  description = "Step Functions state machine ARN that starts Bedrock KB ingestion after DataSync success."
  value       = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync && var.enable_bedrock_kb_sync ? aws_sfn_state_machine.regaffairs_kb_refresh[0].arn : null
}

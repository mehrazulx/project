resource "aws_iam_role" "eventbridge_start_sfn" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync && var.enable_bedrock_kb_sync ? 1 : 0

  name = "${var.project_name}-events-start-bedrock-sync"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_start_sfn" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync && var.enable_bedrock_kb_sync ? 1 : 0

  name = "${var.project_name}-events-start-bedrock-sync"
  role = aws_iam_role.eventbridge_start_sfn[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["states:StartExecution"]
        Resource = aws_sfn_state_machine.regaffairs_kb_refresh[0].arn
      }
    ]
  })
}

resource "aws_iam_role" "sfn_bedrock_ingestion" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync && var.enable_bedrock_kb_sync ? 1 : 0

  name = "${var.project_name}-sfn-bedrock-ingestion"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sfn_bedrock_ingestion" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync && var.enable_bedrock_kb_sync ? 1 : 0

  name = "${var.project_name}-sfn-bedrock-ingestion"
  role = aws_iam_role.sfn_bedrock_ingestion[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:StartIngestionJob"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_sfn_state_machine" "regaffairs_kb_refresh" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync && var.enable_bedrock_kb_sync ? 1 : 0

  name     = "${var.project_name}-regaffairs-kb-refresh"
  role_arn = aws_iam_role.sfn_bedrock_ingestion[0].arn

  definition = jsonencode({
    Comment = "Start Bedrock Knowledge Base ingestion after DataSync success"
    StartAt = "StartIngestionJob"
    States = {
      StartIngestionJob = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:bedrockagent:startIngestionJob"
        Parameters = {
          KnowledgeBaseId = var.bedrock_knowledge_base_id
          DataSourceId    = var.bedrock_data_source_id
        }
        End = true
      }
    }
  })
}

resource "aws_cloudwatch_event_rule" "datasync_success" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync && var.enable_bedrock_kb_sync ? 1 : 0

  name        = "${var.project_name}-datasync-success"
  description = "Triggers Bedrock KB sync when DataSync task succeeds"

  event_pattern = jsonencode({
    source      = ["aws.datasync"]
    detail-type = ["DataSync Task Execution State Change"]
    detail = {
      State   = ["SUCCESS"]
      TaskArn = [aws_datasync_task.regaffairs_weekly[0].arn]
    }
  })
}

resource "aws_cloudwatch_event_target" "datasync_success_sfn" {
  count = var.enable_regaffairs_ingestion && var.enable_regaffairs_datasync && var.enable_bedrock_kb_sync ? 1 : 0

  rule     = aws_cloudwatch_event_rule.datasync_success[0].name
  arn      = aws_sfn_state_machine.regaffairs_kb_refresh[0].arn
  role_arn = aws_iam_role.eventbridge_start_sfn[0].arn
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "lambda.amazonaws.com"
        }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
    role       = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_execution" {
    role = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_s3_execution" {
    role       = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy" "lambda_ssm" {
  name = "${var.project_name}-lambda-ssm-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = "arn:aws:ssm:us-east-1:${var.aws_account_id}:parameter/${var.project_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_sqs_queue" "dashboard_dlq" {
    name = "${var.project_name}-dashboard-dlq"
}

resource "aws_sqs_queue" "dashboard" {
    name = "${var.project_name}-dashboard"
    visibility_timeout_seconds = 300

    redrive_policy = jsonencode({
        deadLetterTargetArn = aws_sqs_queue.dashboard_dlq.arn
        maxReceiveCount     = 3
    })
}

resource "aws_sqs_queue" "reporting_dlq" {
    name = "${var.project_name}-reporting-dlq"
}

resource "aws_sqs_queue" "reporting" {
    name = "${var.project_name}-reporting"
    visibility_timeout_seconds = 300

    redrive_policy = jsonencode({
        deadLetterTargetArn = aws_sqs_queue.reporting_dlq.arn
        maxReceiveCount     = 3
    })
}

resource "aws_lambda_function" "lambda_dashboard" {
    filename = "lambda/lambdadashboard.zip"
    function_name = "${var.project_name}-lambda-dashboard"
    role = aws_iam_role.lambda_role.arn
    handler = "lambdadashboard.handler"
    timeout = 60  # seconds

    vpc_config {
     subnet_ids         = var.private_subnet_ids
     security_group_ids = [var.lambda_sg_id]
    }

    runtime = "python3.11"

    environment {
        variables = {
            ENVIRONMENT = "dev"
            LOG_LEVEL   = "INFO"
            REDIS_ENDPOINT   = var.redis_endpoint
            DASHBOARD_QUEUE  = aws_sqs_queue.dashboard.url
        }
    }
}

resource "aws_lambda_function" "lambda_hourly_sync" {
    filename = "lambda/lambdahourlysync.zip"
    function_name = "${var.project_name}-lambda-hourly-sync"
    role = aws_iam_role.lambda_role.arn
    handler = "lambdahourlysync.handler"
    timeout = 60  # seconds

    vpc_config {
     subnet_ids         = var.private_subnet_ids
     security_group_ids = [var.lambda_sg_id]
    }

    runtime = "python3.11"

    environment {
        variables = {
            ENVIRONMENT = "dev"
            LOG_LEVEL   = "INFO"
            DB_ENDPOINT = var.db_endpoint
        }
    }
}

resource "aws_lambda_function" "lambda_reporting" {
    filename = "lambda/lambdareporting.zip"
    function_name = "${var.project_name}-lambda-reporting"
    role = aws_iam_role.lambda_role.arn
    handler = "lambdareporting.handler"
    timeout = 60  # seconds

    vpc_config {
     subnet_ids         = var.private_subnet_ids
     security_group_ids = [var.lambda_sg_id]
    }

    runtime = "python3.11"

    environment {
        variables = {
           ENVIRONMENT      = var.environment
           LOG_LEVEL        = "INFO"
           S3_BUCKET        = var.s3_bucket_name
           REPORTING_QUEUE  = aws_sqs_queue.reporting.url
        }
    }
}

resource "aws_lambda_event_source_mapping" "dashboard_sqs" {
  event_source_arn = aws_sqs_queue.dashboard.arn
  function_name    = aws_lambda_function.lambda_dashboard.arn
  batch_size       = 10
  enabled          = true
}

resource "aws_lambda_event_source_mapping" "reporting_sqs" {
  event_source_arn = aws_sqs_queue.reporting.arn
  function_name    = aws_lambda_function.lambda_reporting.arn
  batch_size       = 10
  enabled          = true
}

resource "aws_cloudwatch_event_rule" "scheduled" {
  name                = "hourly-sync"            
  description         = "Hourly Sync of Finance Dashboard"
  schedule_expression = "rate(1 hour)"              

  tags = {
    Name        = "${var.project_name}-hourly-sync"
    Environment = var.environment         
    Project     = var.project_name  
  }
}

resource "aws_cloudwatch_event_target" "scheduled_lambda" {
  rule = aws_cloudwatch_event_rule.scheduled.name
  arn  = aws_lambda_function.lambda_hourly_sync.arn                   
}

resource "aws_lambda_permission" "eventbridge_scheduled" {
  statement_id  = "AllowScheduledEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_hourly_sync.function_name               
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled.arn
}

resource "aws_cloudwatch_event_rule" "end_of_month" {
  name                = "reporting"            
  description         = "End of Month Reports"
  schedule_expression = "cron(0 0 1 * ? *)"              

  tags = {
    Name        = "${var.project_name}-reporting"
    Environment = var.environment         
    Project     = var.project_name  
  }
}

resource "aws_cloudwatch_event_target" "end_of_month_lambda" {
  rule = aws_cloudwatch_event_rule.end_of_month.name
  arn  = aws_lambda_function.lambda_reporting.arn                   
}

resource "aws_lambda_permission" "eventbridge_end_of_month" {
  statement_id  = "AllowEndOfMonthEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_reporting.function_name               
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.end_of_month.arn
}
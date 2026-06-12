resource "aws_sns_topic" "alerts" {
  name = "finflow-alerts"                     

  tags = {
    Name        = "${var.project_name}-finflow-alerts"
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint = var.alert_email              

}

resource "aws_cloudwatch_log_group" "lambda_dashboard" {
  name              = "/aws/lambda/lambda_dashboard"      
                                                   
  retention_in_days = 30                      # 7 — dev, 30 — standard prod, 90 — compliance

  tags = {
    Name        = "${var.project_name}-dashboard-log-group"
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "lambda_hourly_sync" {
  name              = "/aws/lambda/lambda_hourly_sync"      
                                                   
  retention_in_days = 30                      # 7 — dev, 30 — standard prod, 90 — compliance

  tags = {
    Name        = "${var.project_name}-hourly-sync-log-group"
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_log_group" "lambda_reporting" {
  name              = "/aws/lambda/lambda_reporting"      
                                                   
  retention_in_days = 30                      # 7 — dev, 30 — standard prod, 90 — compliance

  tags = {
    Name        = "${var.project_name}-reporting-log-group"
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_dashboard_errors" {
  alarm_name          = "${var.project_name}-lambda-dashboard-errors"   
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1    
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60 
  statistic           = "Sum"
  threshold           = 0  
  alarm_description   = "Dahsboard Lambda is throwing errors"

  dimensions = {
    FunctionName = var.lambda_dashboard_name     
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_hourly_sync_errors" {
  alarm_name          = "${var.project_name}-lambda-hourly-sync-errors"   
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1    
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60 
  statistic           = "Sum"
  threshold           = 0  
  alarm_description   = "Hourly Sync Lambda is throwing errors"

  dimensions = {
    FunctionName = var.lambda_hourly_sync_name     
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_reporting_errors" {
  alarm_name          = "${var.project_name}-lambda-reporting-errors"   
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1    
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60 
  statistic           = "Sum"
  threshold           = 0  
  alarm_description   = "Reporting Lambda is throwing errors"

  dimensions = {
    FunctionName = var.lambda_reporting_name     
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "finflow-rds-cpu"              
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2                           
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300                        
  statistic           = "Average"
  threshold           = 80                          
  alarm_description   = "RDS CPU utilization is high"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_identifier
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "dashboard_dlq_depth" {
  alarm_name          = "finflow-dashboard-dlq-depth"     
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0                    
  alarm_description   = "Messages are landing in the Dashboard Dead Letter Queue"

  dimensions = {
    QueueName = var.dashboard_dlq_name  
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_cloudwatch_metric_alarm" "reporting_dlq_depth" {
  alarm_name          = "finflow-reporting-dlq-depth"     
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0                    
  alarm_description   = "Messages are landing in the Reporting Dead Letter Queue"

  dimensions = {
    QueueName = var.reporting_dlq_name  
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = {
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "${var.project_name}-cloudtrail-logs-${var.aws_account_id}"           
                                                    
  force_destroy = true                              
                                                

  tags = {
    Name        = "${var.project_name}-cloudtrail-bucket"
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${var.aws_account_id}/*"
                                                    
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "finflow-trail"      
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true              
  is_multi_region_trail         = true              
  enable_log_file_validation    = true              
                                                    
 
  cloud_watch_logs_group_arn = "${var.cloudwatch_log_group_arn}:*"
                                                    
  cloud_watch_logs_role_arn  = var.cloudtrail_role_arn
                                                    
  depends_on = [aws_s3_bucket_policy.cloudtrail]   

  tags = {
    Name        = "${var.project_name}-trail"
    Environment = var.environment         
    Project     = var.project_name
  }
}
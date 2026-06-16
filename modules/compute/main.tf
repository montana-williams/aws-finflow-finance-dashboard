resource "aws_lb" "finflow_alb" {
  name               = "finflow-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
                                                     

  enable_deletion_protection = false              # FILL IN: set true in production to prevent
                                                  # accidental deletion  
  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment         
    Project     = var.project_name              
  }
}

resource "aws_lb_target_group" "main" {
  name     = "finflow-tg"                               
  port     = 8080                                     
  protocol = "HTTP"                                 
                                                    
  vpc_id   = var.vpc_id                             

  health_check {
    enabled             = true
    path                = "/health"                 # FILL IN: your app health check endpoint
                                                    # must return 200 OK when healthy
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2                         # healthy after 2 consecutive successes
    unhealthy_threshold = 3                         # unhealthy after 3 consecutive failures
    timeout             = 5                         # seconds to wait for response
    interval            = 30                        # seconds between health checks
    matcher             = "200"                     # expected response code
  }

  tags = {
    Name        = "${var.project_name}-lb-tg"
    Environment = var.environment         
    Project     = var.project_name
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.finflow_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # Current recommended TLS policy
  certificate_arn   = var.acm_certificate_arn                 # FILL IN: your ACM certificate ARN
                                                              # Create in ACM console before deploying

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.finflow_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"                     # Permanent redirect
    }
  }
}

resource "aws_launch_template" "main" {
  name = var.project_name

   iam_instance_profile {
    name = var.iam_instance_profile_name
   }

  image_id = var.ami_id

  instance_type = var.instance_type

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [var.app_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
    Name        = "${var.project_name}-ec2"
    Environment = var.environment         
    Project     = var.project_name
    }
  }
}

resource "aws_autoscaling_group" "main" {
  name                = "finflow-asg"              
  min_size            = 2                            
  desired_capacity    = 2                            
  max_size            = 6                            

  vpc_zone_identifier = var.private_subnet_ids
                                                     
  target_group_arns   = [aws_lb_target_group.main.arn]       

  health_check_type         = "ELB"                  
  health_check_grace_period = 300                    
                                                     

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"                              
  }

  tag {
    key                 = "Name"
    value               = "finflow-asg-instance"         
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${var.project_name}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0                              

  }
}
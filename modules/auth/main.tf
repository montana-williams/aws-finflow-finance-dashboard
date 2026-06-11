resource "aws_cognito_user_pool" "finflow" {
    name = "${var.project_name}-customer-pool"

    password_policy {
        minimum_length    = 12
        require_uppercase = true 
        require_lowercase = true
        require_numbers   = true
        require_symbols   = true
    }

    auto_verified_attributes = ["email"]
    username_attributes = ["email"]

    mfa_configuration = "OPTIONAL"

account_recovery_setting {
  recovery_mechanism {
    name     = "verified_email"
    priority = 1
  }
}

tags = {
  Name        = "${var.project_name}-user-pool"
  Environment = var.environment
  Project     = var.project_name
}
}

resource "aws_cognito_user_pool_client" "finflow" {
    name         = "${var.project_name}-client"
    user_pool_id = aws_cognito_user_pool.finflow.id

    generate_secret = false

    explicit_auth_flows = [
  "ALLOW_USER_PASSWORD_AUTH",
  "ALLOW_REFRESH_TOKEN_AUTH"
]

tags = {
  Name        = "${var.project_name}-client"
  Environment = var.environment
  Project     = var.project_name
}
}
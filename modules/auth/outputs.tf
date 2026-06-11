output "user_pool_id" {
    description = "Cognito User Pool ID"
    value       = aws_cognito_user_pool.finflow.id
}

output "user_pool_client_id" {
    description = "Cognito User Pool client ID"
    value       = aws_cognito_user_pool_client.finflow.id
}
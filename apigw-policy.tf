resource "aws_iam_role_policy_attachment" "attach_apigateway_service_role_policy" {
  role       = "APIGatewayAuthorizerRole"  # Nome da sua role existente
  policy_arn = "arn:aws:iam::aws:policy/APIGatewayServiceRolePolicy"  # ARN da política do API Gateway
}

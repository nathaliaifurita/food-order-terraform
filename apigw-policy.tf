resource "aws_iam_role_policy_attachment" "attach_apigateway_service_role_policy" {
  role       = var.principalArn
  policy_arn = var.policyArnApiGatewayAuthorizer
}

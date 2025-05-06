resource "aws_iam_role_policy_attachment" "attach_authorizer_policy" {
  principal_arn = var.principalArn
  policy_arn    = var.policyArnApiGatewayAuthorizer
}

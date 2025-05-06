resource "aws_iam_role_policy_attachment" "attach_authorizer_policy" {
  role          = basename(var.labRole)
  policy_arn    = var.policyArnApiGatewayAuthorizer
}

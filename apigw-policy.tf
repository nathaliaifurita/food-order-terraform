resource "apigw_policy_association" "attach_authorizer_policy" {
  role          = var.labRole
  policy_arn    = var.policyArnApiGatewayAuthorizer
}

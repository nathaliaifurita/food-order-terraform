resource "aws_iam_role" "apigw_authorizer_role" {
  name = "APIGatewayAuthorizerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "apigateway.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.apigw_authorizer_role.name
  policy_arn = var.policyArnApiGatewayAuthorizer
}
resource "aws_iam_role" "apigw_authorizer_role" {
  name = "apigw-authorizer-role"

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

resource "aws_iam_policy" "apigw_authorizer_policy" {
  name        = "apigw-authorizer-policy"
  description = "Policy for API Gateway to invoke authorizer"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow"
        Action    = "execute-api:Invoke"
        Resource  = "*"
      },
      {
        Effect    = "Allow"
        Action    = "logs:CreateLogStream"
        Resource  = "arn:aws:logs:*:*:*"
      },
      {
        Effect    = "Allow"
        Action    = "logs:PutLogEvents"
        Resource  = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "apigw_policy_association" "attach_authorizer_policy" {
  role          = aws_iam_role.apigw_authorizer_role.name
  policy_arn    = var.policyArnApiGatewayAuthorizer
}

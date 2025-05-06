resource "aws_api_gateway_rest_api" "food_order_api" {
  name        = "food-order-vpc-link"
  description = "API Gateway para o Food Order API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_vpc_link" "auth" {
  name        = "auth-vpc-link"
  description = "VPC Link para o serviço de autenticação"
  target_arns = [aws_lb.auth.arn]
}

resource "aws_api_gateway_authorizer" "auth" {
  name                   = "fargate-authorizer"
  rest_api_id           = aws_api_gateway_rest_api.food_order_api.id
  type                  = "REQUEST"
  identity_source       = "method.request.header.CPF"
  authorizer_uri        = "http://${aws_lb.auth.dns_name}/auth"
  authorizer_credentials = var.policyArnApiGatewayAuthorizer
}

# Recurso proxy para todas as rotas
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.food_order_api.id
  parent_id   = aws_api_gateway_rest_api.food_order_api.root_resource_id
  path_part   = "{proxy+}"
}

# Método que será aplicado a todas as rotas
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.food_order_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.auth.id

  request_parameters = {
    "method.request.header.CPF" = true  # Torna o header CPF obrigatório
  }
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = aws_api_gateway_rest_api.food_order_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.auth.id
  uri                     = "http://${aws_lb.auth.dns_name}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_rest_api_policy" "api_policy" {
  rest_api_id = aws_api_gateway_rest_api.food_order_api.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "execute-api:Invoke"
        Resource = "${aws_api_gateway_rest_api.food_order_api.execution_arn}/*"
      }
    ]
  })
}

resource "aws_api_gateway_rest_api" "food_order_api" {
  name        = "food-order-vpc-link"
  description = "API Gateway para o Food Order API"
  target_arns = [aws_lb.food_order_lb.arn]
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.food_order_api.id
  parent_id   = aws_api_gateway_rest_api.food_order_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.food_order_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "load_balancer" {
  rest_api_id             = aws_api_gateway_rest_api.food_order_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id          = aws_api_gateway_vpc_link.food_order.id
  uri                     = "http://${aws_lb.food_order_lb.dns_name}"
}

resource "aws_api_gateway_deployment" "food_order_api" {
  depends_on = [aws_api_gateway_integration.load_balancer]
  rest_api_id = aws_api_gateway_rest_api.food_order_api.id
  stage_name  = "prod"
}
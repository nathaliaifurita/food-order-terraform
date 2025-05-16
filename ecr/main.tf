resource "aws_ecr_repository" "foodorder_cardapio" {
  name = "japamanoel/foodorder_cardapio"  # use exatamente o nome que vai usar no push

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "prod"
    Project     = "FoodOrder"
  }
}

resource "aws_ecr_repository" "foodorder_usuarios" {
  name = "vilacaro/api"  # use exatamente o nome que vai usar no push

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "prod"
    Project     = "FoodOrder"
  }
}

resource "aws_ecr_repository" "foodorder_pedido" {
  name = "vilacaro/pedido"  # use exatamente o nome que vai usar no push

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "prod"
    Project     = "FoodOrder"
  }
}

resource "aws_ecr_repository" "foodorder_pagamento" {
  name = "diegogl12/food-order-pagamento"  # use exatamente o nome que vai usar no push

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "prod"
    Project     = "FoodOrder"
  }
}

  resource "aws_ecr_repository" "foodorder_producao_lanches" {
  name = "diegogl12/food-order-producao"  # use exatamente o nome que vai usar no push

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "prod"
    Project     = "FoodOrder"
  }
}

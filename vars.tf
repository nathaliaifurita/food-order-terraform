variable "regionDefault" {
  default = "us-east-1"
}

variable "projectName" {
  default = "EKS-FOOD-ORDER-API"
}

variable "labRole" {
  default = "arn:aws:iam::916083420257:role/LabRole"
}

variable "accessConfig" {
  default = "API_AND_CONFIG_MAP"
}

variable "nodeGroup" {
  default = "food-order-api-node-group"
}

variable "instanceType" {
  default = "t3.medium"
}

variable "principalArn" {
  default = "arn:aws:iam::916083420257:role/voclabs"
}

variable "policyArn" {
  default = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas"
  default     = []
}

variable "environment" {
  default = "Production-2"
}

variable "cluster_ca_certificate" {
  default = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJVitYRDBZa1ZVbDR3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBek1qUXlNekUyTXpoYUZ3MHpOVEF6TWpJeU16SXhNemhhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUNmWkt2VTIwUEMyaUIyaWNiNkMvWU9NUG9kS0Y1NnBuYjR5bFI2anV2a1E1Y09nRHA4czEwRFoxOWEKRnJWdVk4bWYzSnNNWGxyQXUzUWhpVlJZS2dFOEMyUHVFa2ltckxQNll6VWVtTnRVZ1oweGs2SHVJNjlTOHZMNgpUQ0pLRjI0a2RMUjVNUFE0d0lKZGNQeTlYOG55MWFkQkZQYi9tWHBMWHlIaHNZc2RmNVpmZ0M3UElsNXlWb3RSCm04LzBLUm0yQUNGeFNsc25OaVNtS1FWWE9vbDlHN2doUXBLdVdGdlpnbDNPNk0rMTFMOUZjZWNrUWV5cFdkRisKVjNiZTh2QXVPMTNnVHlpVHI3THlrNWVkV1BadGYrc2JaVVBISklCdmZHYjV5Z1NvcHBhQ0tDbXV2M3lTKzd5SApSTVFiRFhYeFdZTm1mOVM0di9sQW9jaEJSSnNEQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJRL2JjL2hzbUlmTTkvb0MvNHh5bzBvQkxmS0tqQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ0ZZeUpBK2tUUgpKNUthaUxCZXlpYWlCUS9VVW01ZDhqZ1JkQTV2TFVMenpHcTVzS3JDN2l6M2w2SURQbU5SU254aEQ2ZStKR0xZCmJ2V1V0L1ZESmw0YWZjRFZGYTZROGN1ZmR6VUE1aGdtaWdGcTFiSzd4R0tRVDNVdkVVTDN3c3hMcjJJa1ZjNnkKQXI4Q0ExQlVEV0VYVUlVbHRQOWVkT2prdHNseDZyVFIxQmdLZHJsVUtsTnMzRXFSQnBnZFdURW5qTmNJaWc2NgpoMi9kUnZvd3YrdDlaSmJRUUo2UTEza2pnMEx0NituaXhIbjVRd2NCRkV4M3RwUjNNemNURGFZQW9Fd0d2THRjCjdpWHRqd1lQNHkra2ZlRkV0NTZoYjNwQ0kyR2ZIaEpHaG9FMEE3eVgzUVJ2SEZUNGN4QjB5YldMTTlKRitGTEkKQjliZlZKKzBKTTMrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
}

variable "host" {
  default = "https://44D1148160562566D5A10AF77BC7C905.gr7.us-east-1.eks.amazonaws.com"
}

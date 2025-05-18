variable "create_vpc" {
  description = "Cria nova VPC se true, reutiliza se false"
  type        = bool
  default     = false
}

variable "create_subnets" {
  description = "Cria novas subnets se true, reutiliza se false"
  type        = bool
  default     = false
}

variable "vpc_cidr_block" {
  description = "CIDR da VPC"
  type        = string
  default     = "172.31.0.0/16"
}

variable "availability_zones" {
  description = "Lista de zonas de disponibilidade"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "project_name" {
  description = "Nome do projeto (para tags e nomes)"
  type        = string
}

variable "tags" {
  description = "Tags padrões"
  type        = map(string)
  default     = {}
}

variable "create_security_group" {
  description = "Define se o SG deve ser criado"
  type        = bool
  default     = false
}

variable "security_group_ingress" {
  description = "Lista de regras de entrada"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "security_group_egress" {
  description = "Lista de regras de saída"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

//variable "create_rds" {
//  description = "Define se o RDS deve ser criado"
//  type        = bool
//  default     = false
//}
//
//variable "rds_instance_class" {
//  description = "Classe da instância RDS"
//  type        = string
//  default     = "db.t3.micro"
//}
//
//variable "rds_engine" {
//  description = "Engine do banco"
//  type        = string
//  default     = "postgres"
//}
//
//variable "rds_engine_version" {
//  description = "Versão do engine"
//  type        = string
//  default     = "15.3"
//}
//
//variable "rds_username" {
//  description = "Usuário administrador do banco"
//  type        = string
//  default     = "admin"
//}
//
//variable "rds_password" {
//  description = "Senha do banco"
//  type        = string
//  sensitive   = true
//}
//
//variable "rds_allocated_storage" {
//  description = "Tamanho em GB"
//  type        = number
//  default     = 20
//}
//
//variable "rds_skip_final_snapshot" {
//  description = "Pular snapshot final ao destruir"
//  type        = bool
//  default     = true
//}
//
//variable "rds_multi_az" {
//  description = "Ativar Multi-AZ"
//  type        = bool
//  default     = false
//}
//
//variable "rds_deletion_protection" {
//  description = "Proteção contra deleção"
//  type        = bool
//  default     = true
//}
//
//variable "rds_backup_retention_period" {
//  description = "Dias de retenção do backup"
//  type        = number
//  default     = 7
//}
//
//variable "rds_storage_encrypted" {
//  description = "Habilita criptografia no armazenamento"
//  type        = bool
//  default     = true
//}
//
//variable "rds_apply_immediately" {
//  description = "Aplicar mudanças imediatamente"
//  type        = bool
//  default     = true
//}
//

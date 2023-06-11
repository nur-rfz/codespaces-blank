variable "database_name" {
  description = "Wordpress database name"
  type        = string
  default     = "wordpress_db"
}

variable "database_master_username" {
  description = "Wordpress database master username"
  type        = string
  default     = "wordpress_dbuser"
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
}

variable "cluster_instance_class" {
  description = "instance class for rds instance"
  type        = string
  default     = "db.t2.micro"
}

variable "wordpress_external_port" {
  description = "port to access from internet"
  type        = number
  default     = 8080
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "domain" {
  description = "wordpress domain"
  type        = string
  default     = "case915.wordpress.com"
}

variable "endpoint" {
  description = "wordpress endpoint"
  type        = string
  default     = "wp"
}
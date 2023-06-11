resource "aws_rds_cluster" "wordpress" {
  cluster_identifier     = "wordpress-cluster"
  engine                 = "aurora-mysql"
  engine_version         = "5.7.mysql_aurora.2.08.3"
  availability_zones     = data.aws_availability_zones.zones.names
  database_name          = aws_ssm_parameter.dbname.value
  master_username        = aws_ssm_parameter.dbuser.value
  master_password        = aws_ssm_parameter.dbpassword.value
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.id
  engine_mode            = "serverless"
  vpc_security_group_ids = [aws_security_group.rds_secgrp.id]

  scaling_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  tags = local.tags
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.4.0/24"  
  availability_zone       = "eu-central-1a"
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.2.0/24"  
  availability_zone       = "eu-central-1b"
}

resource "aws_subnet" "subnet_c" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.3.0/24"  
  availability_zone       = "eu-central-1c"
}

resource "aws_ssm_parameter" "dbname" {
  name  = "/app/wordpress/DATABASE_NAME"
  type  = "String"
  value = var.database_name
  overwrite = true
}

resource "aws_ssm_parameter" "dbuser" {
  name  = "/app/wordpress/DATABASE_MASTER_USERNAME"
  type  = "String"
  value = var.database_master_username
  overwrite = true
}

resource "aws_ssm_parameter" "dbpassword" {
  name  = "/app/wordpress/DATABASE_MASTER_PASSWORD"
  type  = "SecureString"
  value = random_password.password.result
  overwrite = true
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_db_subnet_group" "dbsubnet" {
  name        = "dbsubnet_nurrfz"
  description = "dbsubnet for the Nur"
  subnet_ids  = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id, aws_subnet.subnet_c.id ]
  tags        = local.tags
}


resource "aws_security_group" "rds_secgrp" {
  name        = "wordpress rds access"
  description = "RDS secgroup"
  vpc_id      = var.vpc_id

  ingress {
    description = "VPC bound"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }

  tags = local.tags
}

resource "aws_instance" "wordpress" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet_a.id
  security_groups             = [aws_security_group.ec2_secgrp.id]
  iam_instance_profile        = "ec2_profile"
  user_data                   = data.template_file.userdata.rendered

  tags = merge(local.tags, {
    Name = "wordpress-isntance"
  })
}

resource "aws_security_group" "ec2_secgrp" {
  name        = "wordpress-instance-secgrp"
  description = "wordpress instance secgrp"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.wordpress_external_port
    to_port     = var.wordpress_external_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags

}
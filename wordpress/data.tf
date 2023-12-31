data "aws_availability_zones" "zones" {
  state = "available"
}

data "aws_subnets" "subnets" {
    filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "template_file" "dockercompose" {
  template = file("./template/docker-compose.tpl")

  vars = {
    dbhost        = aws_rds_cluster.wordpress.endpoint
    dbuser        = aws_rds_cluster.wordpress.master_username
    dbpassword    = aws_rds_cluster.wordpress.master_password
    dbname        = aws_rds_cluster.wordpress.database_name
    external_port = var.wordpress_external_port
  }
}
data "template_file" "nginx_conf" {
  template = file("./template/server-conf.tpl")

  vars = {
    external_port = var.wordpress_external_port
  }
}

data "template_file" "userdata" {
  template = file("./template/userdata.tpl")

  vars = {
    dockercompose = data.template_file.dockercompose.rendered
    nginx_conf    = data.template_file.nginx_conf.rendered
  }

}
resource "aws_vpc" "RAYMOND" {
  cidr_block       = var.vpc-cidr
  instance_tenancy = "default"

  tags = {
    Name = "RAYMOND"
  }
}

resource "aws_subnet" "Raymond" {
  vpc_id                  = aws_vpc.RAYMOND.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.azs


  tags = {
    Name = "Raymond"
  }
}

resource "aws_instance" "ray_instance" {

  ami                    = "ami-04cb4ca688797756f"
  instance_type          = var.instancetype
  key_name               = var.keypair
  subnet_id              = aws_subnet.Raymond.id
  vpc_security_group_ids = [aws_security_group.ray-sg.id]

  user_data = file("shellscript.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "ray_instance"
  }

}

resource "aws_internet_gateway" "ray_ig" {
  vpc_id = aws_vpc.RAYMOND.id

  tags = {
    Name = "raymond_ig"
  }
}

resource "aws_route_table" "ray_public_rt" {
  vpc_id = aws_vpc.RAYMOND.id


  tags = {
    Name = "raymond_public_rt"
  }
}


resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.ray_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ray_ig.id

}


resource "aws_route_table_association" "ray_association" {
  subnet_id      = aws_subnet.Raymond.id
  route_table_id = aws_route_table.ray_public_rt.id
}


resource "aws_security_group" "ray-sg" {
  name        = "ray-sg"
  description = "Allow http traffic"
  vpc_id      = aws_vpc.RAYMOND.id

  ingress {
    description = "Allow http traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  ingress {
    description = "Allow ssh traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ray-sg"
  }
}

output "server-ip" {
  value = aws_instance.ray_instance.public_ip
}

output "vpc_id" {
  value = aws_vpc.RAYMOND.id
}

output "server-arn" {
  value = aws_instance.ray_instance.arn
}
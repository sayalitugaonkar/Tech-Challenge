
provider "aws" {
    region = "${var.AWS_REGION}"
}



resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "myvpc_main"
  }
}

# //Create Public Subnet


//Create Internet Gateway
resource "aws_internet_gateway" "prod-igw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "prod-igw"
    }
}

resource "aws_subnet" "prod-subnet-public-1" {
     vpc_id = aws_vpc.main.id
     cidr_block = "10.0.1.0/24"
     map_public_ip_on_launch = "true" //it makes this a public subnet
     availability_zone = "${var.AWS_AZ}"    
     depends_on = [aws_internet_gateway.prod-igw]
     tags = {
         Name = "prod-subnet-public-1"
     }
 }
//Create Custom Route Table
resource "aws_route_table" "prod-public-crt" {
    vpc_id = aws_vpc.main.id
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0"         //CRT uses this IGW to reach internet
        gateway_id = aws_internet_gateway.prod-igw.id
    }
    
    tags = {
        Name = "prod-public-crt"
    }
}

//Associate CRT and Subnet

resource "aws_route_table_association" "prod-crta-public-subnet-1"{
    subnet_id = aws_subnet.prod-subnet-public-1.id
    route_table_id = aws_route_table.prod-public-crt.id
}

//Create private Subnet
resource "aws_subnet" "prod-subnet-private-1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "false" //it makes this a private subnet
 //   availability_zone ="${var.AWS_AZ}"    
    tags = {
        Name = "prod-subnet-private-1"
    }
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

// create public NAT gateway
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.prod-subnet-public-1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.prod-igw]
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = aws_vpc.main.id
}


resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "ssh from bastion"
    from_port        = 22
    to_port          = 22
    cidr_blocks = ["0.0.0.0/0"]
    protocol         = "tcp"

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}




resource "aws_instance" "Bastion" {
  instance_type = "t2.micro"
  ami = "${var.ami_bastion}" 
  key_name = "Sayali_mac"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id,"${data.aws_security_group.default.id}"]
  subnet_id     = aws_subnet.prod-subnet-public-1.id  
  tags = {
    "Name" = "Bastion_server"
  }
}

resource "aws_instance" "ec2instance" {
  instance_type = "t3a.medium"
  ami = "${var.ami}" 
  subnet_id = aws_subnet.prod-subnet-private-1.id
  disable_api_termination = false

  ebs_optimized = false
  key_name = "Bastion"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id,"${data.aws_security_group.default.id}"]
  depends_on        = [aws_nat_gateway.example]
  root_block_device {
    volume_size = "10"
  }
  tags = {
    "Name" = "Magento_Server01"
  }
}
output "instance_private_ip" {
  value = aws_instance.ec2instance.private_ip
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/xvda"
  volume_id   = aws_ebs_volume.example_ebs.id
  instance_id = aws_instance.ec2instance.id
}


resource "aws_ebs_volume" "example_ebs" {
  availability_zone = "${var.AWS_AZ}" 
  size = 1 
  type = "gp3"
}


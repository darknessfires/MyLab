terraform {
 required_providers {
    aws ={
        source = "hashicorp/aws"
            version ="~>3.0"
    }
 }
}

# configure the AWS provider

provider "aws" {
    region = "eu-west-1"

}

# create a VPC

resource "aws_vpc" "MyLab-VPC" {
    cidr_block = var.cidr_block[0]

    tags = {
        Name = "MyLab-VPC"
    }
}

# Create Subnet (Public)

resource "aws_subnet" "MyLab-Subnet1" {
   vpc_id = aws_vpc.MyLab-VPC.id
   cidr_block = var.cidr_block[1]

   tags = {
       Name = "MyLab-Subnet1"
   }
}

# Create Internet Gateway

resource "aws_internet_gateway" "MyLab-IntGW" {
    vpc_id =  aws_vpc.MyLab-VPC.id

    tags = {
        Name = "MyLab-InternetGW"
    }
}

# Create Security Group

resource "aws_security_group" "MyLab_Sec_Group" {
    name = "MyLab Security Group"
    description = "To allow inbound and outbound traffic to mylab"
    vpc_id = aws_vpc.MyLab-VPC.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
           
        }
        
  
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow traffic"
    
    }        
}
     
    # Create route table and association

resource "aws_route_table" "MyLab_RouteTable" {
    vpc_id = aws_vpc.MyLab-VPC.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.MyLab-IntGW.id
        }

        tags = {
            Name = "MyLab_Routetable"
        }
                
    }

resource "aws_route_table_association" "MyLab_Assn" {
    subnet_id = aws_subnet.MyLab-Subnet1.id
    route_table_id = aws_route_table.MyLab_RouteTable.id 
}
  
  # Create an AWS EC2 Instance

  resource "aws_instance" "Jenkins" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "EC2"
  vpc_security_group_ids = [aws_security_group.MyLab_Sec_Group.id]
  subnet_id = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data = "value"

  tags = {
    Name = "Jenkins-Server"
  }
}

 #Create/Launch an AWS EC2 Instance(Ansible Manager node1) to host Apache tomcat server
  
 resource "aws_instance" "AnsibleManagerNode1" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "EC2"
  vpc_security_group_ids = [aws_security_group.MyLab_Sec_Group.id]
  subnet_id = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data = file ("./AnsibleManagedNode.sh")

  tags = {
    Name = "AnsibleMN-ApacheTomcat"
  }
}


#Create/Launch an AWS Instance(Ansible Managed Node2) to host Docker

 resource "aws_instance" "DockerHost" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "EC2"
  vpc_security_group_ids = [aws_security_group.MyLab_Sec_Group.id]
  subnet_id = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data = file ("./Docker.sh")

  tags = {
    Name = "DockerHost"
  }
}

# Create-Launch an AWS EC2 Instance to host Sonaytype Nexus

resource "aws_instance" "Nexus" {
  ami           = var.ami
  instance_type = var.instance_type_for_nexus
  key_name = "EC2"
  vpc_security_group_ids = [aws_security_group.MyLab_Sec_Group.id]
  subnet_id = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data = file ("./InstallNexus.sh")

  tags = {
    Name = "Nexus-Server"
  }
}
provider "aws" {
    region                  = "us-east-1" 
}
resource "aws_instance" "server" {
  ami = "ami-2d39803a"
  instance_type = "t2.micro"
  tags = {
      Name          = "server-one"
      Environment   = "Production"
      App           = "ecommerce"
  }
}

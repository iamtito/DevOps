####################################################################################
##
##  Name: Example 1
##  Description: Spin up One ec2 instance
##
####################################################################################
provider "aws" {
    region                  = "us-east-1" 
    shared_credentials_file = "/PATH/TO/AWS/CONFIG"
    profile                 = "myAWSprofile"
}
resource "aws_instance" "server" {
  ami = "ami-2d39803a"
  instance_type = "t2.micro"
  tags {
      Name          = "server-one"
      Environment   = "Production"
      App           = "ecommerce"
  }
}

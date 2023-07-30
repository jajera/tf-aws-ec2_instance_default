# create rg, list created resources
resource "aws_resourcegroups_group" "example" {
  name        = "tf-rg-example"
  description = "Resource group for example resources"

  resource_query {
    query = <<JSON
    {
      "ResourceTypeFilters": [
        "AWS::AllSupported"
      ],
      "TagFilters": [
        {
          "Key": "Owner",
          "Values": ["John Ajera"]
        }
      ]
    }
    JSON
  }

  tags = {
    Name  = "tf-rg-example"
    Owner = "John Ajera"
  }
}

# create vpc
resource "aws_default_vpc" "example" {

  tags = {
    Name  = "tf-defaultvpc-example"
    Owner = "John Ajera"
  }
}

# create sg
resource "aws_security_group" "example" {
  name        = "tf-sg-example"
  description = "Security group for example resources"
  vpc_id      = aws_default_vpc.example.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "tf-sg-example"
    Owner = "John Ajera"
  }
}

# get image ami
data "aws_ami" "example" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-8.8.0_HVM-20230623-x86_64-3-Hourly2-GP2"]
  }
}

# get ssh key pair
resource "aws_key_pair" "example" {
  key_name   = "tf-kp-example"
  public_key = file("~/.ssh/id_ed25519_aws_2023-07-30.pub")
}

# create vm
resource "aws_instance" "example" {
  ami                         = data.aws_ami.example.id
  instance_type               = "m5.large"
  key_name                    = aws_key_pair.example.key_name
  vpc_security_group_ids      = [aws_security_group.example.id]
  associate_public_ip_address = true

  lifecycle {
    ignore_changes = [
      associate_public_ip_address
    ]
  }

  tags = {
    Name  = "tf-instance-example"
    Owner = "John Ajera"
  }
}

output "public_ip" {
  value = aws_instance.example.public_ip
}

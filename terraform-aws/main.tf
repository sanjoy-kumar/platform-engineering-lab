
resource "aws_instance" "web_server" {
    ami = "ami-0e5497a77ef21b5ac"
    instance_type = var.instance_type

    tags  = {
        Name = "web-server"
    }

}


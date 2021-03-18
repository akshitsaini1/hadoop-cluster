provider "aws" {
    profile = "akshit"
    region = "ap-south-1"
}
variable "a" {
    default= ["master","slave1","slave2","slave3","client"]
}
resource "aws_instance" "hadoop-cluster" {
  count = length(var.a)
  ami           = "ami-0a9d27a9f4f5c0efc"
  security_groups=["hadoop","launch-wizard-1"]
  root_block_device {
    volume_size= "20"
  }
  instance_type = "t2.micro"
  key_name= "mykey"
  tags = {
    Name = var.a[count.index]
  }
}

output "name" {
  value=aws_instance.hadoop-cluster[*].public_ip
}
output "sg-name" {
  value=aws_instance.hadoop-cluster[0].security_groups

}

resource "local_file" "inventory" {
    depends_on = [ aws_instance.hadoop-cluster, ]
    content     = "[master]\n${aws_instance.hadoop-cluster[0].public_ip}\n[slave]\n${aws_instance.hadoop-cluster[1].public_ip}\n${aws_instance.hadoop-cluster[2].public_ip}\n${aws_instance.hadoop-cluster[3].public_ip}\n[client]\n${aws_instance.hadoop-cluster[4].public_ip}"
    filename = "/home/invincible/Desktop/terraform/loop/inventory.txt"
}


resource "null_resource" "local" {
  depends_on = [ local_file.inventory ]
  provisioner "local-exec" {
    command = "ansible-playbook hadoop.yml "  
    }
}
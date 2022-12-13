resource "aws_instance" "bastion_host" {
  ami           = "ami-0b0dcb5067f052a63" # us-east-1
  instance_type = "t2.micro"

  key_name = aws_key_pair.bastion_host_key.id

  network_interface {
    network_interface_id = aws_network_interface.bastion_host_eni.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-bastion-host-${var.region}b-${random_id.name.hex}"
  }

}

resource "aws_network_interface" "bastion_host_eni" {
  subnet_id   = aws_subnet.vpc_public_subnet_1.id # 10.0.11.0/24
  private_ips = ["10.0.11.100"]

  security_groups = [aws_security_group.bastion_host_sg.id]

  #   interface_type = "branch"

  tags = {
    Name = "${var.project_name}-${terraform.workspace}-bastion-host-eni-${var.region}b-${random_id.name.hex}"
  }
}

resource "aws_key_pair" "bastion_host_key" {
  key_name   = "${var.project_name}-${terraform.workspace}-bastion-host-key-${var.region}b-${random_id.name.hex}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDJemzHkDADkvPPh8RrMTP8PROTxPaVzboi7xDu4aL7KecraBJWyiIG6ObOV2NVI1h8LgsI0LXUpVdssy4PwTDBFzYi1TT3ZRtZgRQblgxbsjJG1vmYqCfF8iiofgJ7nCFR34j7x7GobxgIJbS2Cg1K+A1vUz3aZU/4sclFM7paLecwvPxaiKn0XU9HLhPMgSgqZoZcCH1KvDwHaM2vNgXqsSvgkbs+jqAbuzj/JXqKEaedQUTciBz1qpp9T3iquhLILDslYb5aoGx8UPRBPPlD91hSqWw2tmQ4UT+IIHGH0D98uPoblZH15BGSm2cdnA2+OvXkOhWo8wtoSE1bogeNIGWmrd00QvTXKqTqTaNdpIuhq1kq8Ls+4ABCchE19jO0G3/ExWUe2viStVKsocjzekCE0WygKK8S4cl5hmk8AtoZWfej3/IrHQ2a+UGgei+PQqxgNpFdkZ7LGOlyFrnlZga9ZHf95aoPvbFU5m1odqqkG/zh87DU5uEzlMmHICTsL/MuhiVgU4DOIYhAWQzLnqTP71KvyqSuVPsZKZtfQX5TMxrX1ws4owcogeIFbZD573excr6DB1lIz2GkyEsEt7dfZplJpB+ZY4S2CwJbJs88AmkwIK2dSuYvSpdWr9ubIo0a9QAK2ntaRNmeZ4iINoyndvCdxRZpfntUb3/mpQ== ja.vega.g10@gmail.com"

  tags = {
    "Name" = "${var.project_name}-${terraform.workspace}-bastion-host-key-${var.region}b-${random_id.name.hex}"
  }

}

resource "aws_security_group" "private-node" {
  name        = "private-node"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.demoEKS.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
                "${var.demo-local-infra-private}", 
                "${var.demo-local-infra-public}", 
                "${var.demo-vpn-private}", 
                "${var.demo-vpn-public}", 
                "${var.vpc-cidr}"
            ]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "KubernetesELB" {
  name        = "KubernetesELB"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.demoEKS.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


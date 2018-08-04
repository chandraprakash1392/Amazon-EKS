resource "aws_vpc" "demoEKS" {
  cidr_block = "${var.vpc-cidr}"
  enable_dns_hostnames = true
  tags = "${
    map(
      "Name", "${var.vpc-name}",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

resource "aws_subnet" "public-subnet-1" {
  availability_zone = "${var.availability-zone-1}"
  cidr_block = "${var.public-subnet-1}"
  vpc_id = "${aws_vpc.demoEKS.id}"
  tags = "${
    map(
      "Name", "${var.pubSub1}",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
      )
    }"
}

resource "aws_subnet" "public-subnet-2" {
  availability_zone = "${var.availability-zone-2}"
  cidr_block = "${var.public-subnet-2}"
  vpc_id = "${aws_vpc.demoEKS.id}"
  tags = "${
    map(
      "Name", "${var.pubSub2}",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
      )
    }"
}

resource "aws_subnet" "private-subnet-1" {
  availability_zone = "${var.availability-zone-1}"
  cidr_block = "${var.private-subnet-1}"
  vpc_id = "${aws_vpc.demoEKS.id}"
  tags = "${
    map(
      "Name", "${var.priv-sub-1}",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
      )
    }"
}

resource "aws_subnet" "private-subnet-2" {
  availability_zone = "${var.availability-zone-2}"
  cidr_block = "${var.private-subnet-2}"
  vpc_id = "${aws_vpc.demoEKS.id}"
  tags = "${
    map(
      "Name", "${var.priv-sub-2}",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
      )
    }"
}

resource "aws_subnet" "private-subnet-3" {
  availability_zone = "${var.availability-zone-3}"
  cidr_block = "${var.private-subnet-3}"
  vpc_id = "${aws_vpc.demoEKS.id}"
  tags = "${
    map(
      "Name", "${var.priv-sub-3}",
      "kubernetes.io/cluster/${var.cluster-name}", "shared",
      )
    }"
}

resource "aws_internet_gateway" "publicIG" {
  vpc_id = "${aws_vpc.demoEKS.id}"

  tags {
    Name = "demo EKS internet gateway"
  }
}

resource "aws_eip" "privateEIP1" {
  vpc = true
  tags{
    "Name" = "demo EKS EIP for NAT gateway of private subnet 1"
  }
}

resource "aws_nat_gateway" "privateNG1" {
  allocation_id = "${aws_eip.privateEIP1.id}"
  subnet_id = "${aws_subnet.public-subnet-1.id}"
  tags {
    "Name" = "demo EKS NAT gateway for private subnet 1"
  }
}

resource "aws_eip" "privateEIP2" {
  vpc = true
  tags{
    "Name" = "demo EKS EIP for NAT gateway of private subnet 2"
  }
}

resource "aws_nat_gateway" "privateNG2" {
  allocation_id = "${aws_eip.privateEIP2.id}"
  subnet_id = "${aws_subnet.public-subnet-2.id}"
  tags {
    "Name" = "demo EKS NAT gateway for private subnet 2"
  }
}

resource "aws_eip" "privateEIP3" {
  vpc = true
  tags{
    "Name" = "demo EKS EIP for NAT gateway of private subnet 3"
  }
}

resource "aws_nat_gateway" "privateNG3" {
  allocation_id = "${aws_eip.privateEIP3.id}"
  subnet_id = "${aws_subnet.public-subnet-1.id}"
  tags {
    "Name" = "demo EKS NAT gateway for private subnet 3"
  }
}

resource "aws_vpc_peering_connection" "demoEKS" {
  peer_owner_id = "${var.peer-owner-id}"
  peer_vpc_id   = "${var.peer-accepter-vpc-id}"
  vpc_id        = "${aws_vpc.demoEKS.id}"
  auto_accept   = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags {
    "Name" = "demoEKS-TO-demo-Infra"
  }
}


resource "aws_route_table" "publicRT" {
  vpc_id = "${aws_vpc.demoEKS.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.publicIG.id}"
  }
  route {
    cidr_block = "172.30.0.0/16"
    gateway_id = "${aws_vpc_peering_connection.demoEKS.id}"
  }
}

resource "aws_route_table" "privateRT1" {
  vpc_id = "${aws_vpc.demoEKS.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.privateNG1.id}"
  }
  route {
    cidr_block = "172.30.0.0/16"
    gateway_id = "${aws_vpc_peering_connection.demoEKS.id}"
  }
}

resource "aws_route_table" "privateRT2" {
  vpc_id = "${aws_vpc.demoEKS.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.privateNG2.id}"
  }
  route {
    cidr_block = "172.30.0.0/16"
    gateway_id = "${aws_vpc_peering_connection.demoEKS.id}"
  }
}

resource "aws_route_table" "privateRT3" {
  vpc_id = "${aws_vpc.demoEKS.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.privateNG3.id}"
  }
  route {
    cidr_block = "172.30.0.0/16"
    gateway_id = "${aws_vpc_peering_connection.demoEKS.id}"
  }
}

resource "aws_route_table_association" "publicRTA" {

  subnet_id      = "${aws_subnet.public-subnet-1.id}"
  route_table_id = "${aws_route_table.publicRT.id}"
}

resource "aws_route_table_association" "privateRTA1" {

  subnet_id      = "${aws_subnet.private-subnet-1.id}"
  route_table_id = "${aws_route_table.privateRT1.id}"
}

resource "aws_route_table_association" "privateRTA2" {

  subnet_id      = "${aws_subnet.private-subnet-2.id}"
  route_table_id = "${aws_route_table.privateRT2.id}"
}

resource "aws_route_table_association" "privateRTA3" {

  subnet_id      = "${aws_subnet.private-subnet-3.id}"
  route_table_id = "${aws_route_table.privateRT3.id}"
}
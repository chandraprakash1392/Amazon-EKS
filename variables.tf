variable "default-region" {
    default = "us-west-2"
}

variable "vpc-name" {
  type = "string"
  default = "demoEKS"
}

variable "cluster-name" {
    type = "string"
    default = "demoEKS"
}

variable "vpc-cidr" {
  type = "string"
  default = "172.19.0.0/16"
  description = "The Amazon EKS VPC CIDR block"
}

variable "public-subnet-1" {
    type = "string"
    default = "172.19.1.0/27"
}

variable "public-subnet-2" {
  type = "string"
  default = "172.19.1.64/27"
}


variable "pubSub1" {
  type = "string"
  default = "demo-kubernetes-public-1"
}

variable "pubSub2" {
  type = "string"
  default = "demo-kubernetes-public-2"
}


variable "private-subnet-1" {
    type = "string"
    default = "172.19.2.0/23"
}

variable "priv-sub-1" {
  type = "string"
  default = "demo-kubernetes-private-1"
}


variable "private-subnet-2"{
    type = "string"
    default = "172.19.4.0/23"
}

variable "priv-sub-2" {
  type = "string"
  default = "demo-kubernetes-private-2"
}

variable "private-subnet-3"{
    type = "string"
    default = "172.19.6.0/23"
}

variable "priv-sub-3" {
  type = "string"
  default = "demo-kubernetes-private-3"
}

variable "demo-local-infra-private" {
  type = "string"
  default = "192.168.12.0/24"
}

variable "demo-local-infra-public" {
  type = "string"
  default = ""
}

variable "demo-vpn-private" {
  type = "string"
  default = "192.168.255.0/24"
}

variable "demo-vpn-public" {
  type = "string"
  default = ""
}

variable "availability-zone-1" {
  default = "us-west-2a"
}

variable "availability-zone-2" {
    default = "us-west-2b"
}

variable "availability-zone-3" {
  default = "us-west-2c"
}

variable "peer-owner-id" {
    type = "string"
    default = ""
}

variable "peer-accepter-vpc-id" {
    type = "string"
    default = "vpc-9b0a75fd"
    description = "Peering connection to demo-Infra VPC"
}
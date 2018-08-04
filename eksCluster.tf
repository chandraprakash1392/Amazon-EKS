resource "aws_eks_cluster" "demoEKS" {
  name            = "${var.cluster-name}"
  role_arn        = "${aws_iam_role.demoEKS-master.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.private-node.id}"]
    subnet_ids         = ["${aws_subnet.private-subnet-1.id}", "${aws_subnet.private-subnet-2.id}", "${aws_subnet.private-subnet-3.id}" ]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.demoEKSClusterPolicy",
    "aws_iam_role_policy_attachment.demoEKSServicePolicy",
  ]
}

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.demoEKS.endpoint}
    certificate-authority-data: ${aws_eks_cluster.demoEKS.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster-name}"
KUBECONFIG
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["eks-worker-v18"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.demoEKS-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config-map-aws-auth" {
  value = "${local.config-map-aws-auth}"
}

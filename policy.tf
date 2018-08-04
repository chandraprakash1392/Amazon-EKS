resource "aws_iam_role" "demoEKS-master" {
  name = "demoEKS-master"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


resource "aws_iam_role" "demoEKS-node" {
  name = "demoEKS-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "AddedInlinePolicy" {
  name = "AddedInlinePolicy"
  role = "${aws_iam_role.demoEKS-node.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "tag:GetResources",
        "acm:ListCertificates",
        "iam:ListServerCertificates",
        "waf-regional:GetWebACLForResource"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "demoEKS-node" {
  name = "demoEKS-instance-profile"
  role = "${aws_iam_role.demoEKS-node.name}"
  path = "/"
}

resource "aws_iam_role_policy_attachment" "demoEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.demoEKS-master.name}"
}

# resource "aws_iam_role_policy_attachment" "demoEKSTagResourcesPolicy" {
#   policy_arn = "${aws_iam_role_policy.TagResources.arn}"
#   role       = "${aws_iam_role.demoEKS-node.name}"
# }


resource "aws_iam_role_policy_attachment" "demoEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.demoEKS-master.name}"
}

resource "aws_iam_role_policy_attachment" "demoEKSRoute53PolicyMaster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53DomainsFullAccess"
  role       = "${aws_iam_role.demoEKS-master.name}"
}

resource "aws_iam_role_policy_attachment" "demoEKSRoute53PolicyNode" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53DomainsFullAccess"
  role       = "${aws_iam_role.demoEKS-node.name}"
}
resource "aws_iam_role_policy_attachment" "demoEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.demoEKS-node.name}"
}

resource "aws_iam_role_policy_attachment" "demoEKSRoute53HostedZonePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
  role       = "${aws_iam_role.demoEKS-node.name}"
}

resource "aws_iam_role_policy_attachment" "demoEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.demoEKS-node.name}"
}

resource "aws_iam_role_policy_attachment" "demoEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.demoEKS-node.name}"
}

resource "aws_iam_role_policy_attachment" "demoEC2LoadBalancingELB" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = "${aws_iam_role.demoEKS-node.name}"
}

output "NodeInstanceRole" {
  value = "${aws_iam_role.demoEKS-node.arn}"
}
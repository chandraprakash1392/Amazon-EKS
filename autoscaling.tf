data "aws_region" "current" {}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml
locals {
  demo-node-userdata = <<USERDATA
#!/bin/bash -xe

CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY
echo "${aws_eks_cluster.demoEKS.certificate_authority.0.data}" | base64 -d >  $CA_CERTIFICATE_FILE_PATH
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.demoEKS.endpoint},g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,${var.cluster-name},g /var/lib/kubelet/kubeconfig
sed -i s,REGION,${data.aws_region.current.name},g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,20,g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.demoEKS.endpoint},g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service
systemctl daemon-reload
systemctl restart kubelet
USERDATA
}

resource "aws_launch_configuration" "demoEKS" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.demoEKS-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "m4.xlarge"
  name_prefix                 = "demoEKS-node"
  security_groups             = ["${aws_security_group.private-node.id}"]
  user_data_base64            = "${base64encode(local.demo-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "demoEKS" {
  desired_capacity     = 10
  launch_configuration = "${aws_launch_configuration.demoEKS.id}"
  max_size             = 25
  min_size             = 10
  name                 = "demoEKS"
  vpc_zone_identifier  = [
                        "${aws_subnet.private-subnet-1.id}", 
                        "${aws_subnet.private-subnet-2.id}", 
                        "${aws_subnet.private-subnet-3.id}"
                    ]

  tag {
    key                 = "Name"
    value               = "demoEKS-Node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "demoEKSmemoryOptimized" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.demoEKS-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "r4.large"
  name_prefix                 = "demoEKS-node-memory-optimized"
  security_groups             = ["${aws_security_group.private-node.id}"]
  user_data_base64            = "${base64encode(local.demo-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "demoEKSmemoryOptimized" {
  desired_capacity     = 10
  launch_configuration = "${aws_launch_configuration.demoEKSmemoryOptimized.id}"
  max_size             = 10
  min_size             = 10
  name                 = "demoEKSmemoryOptimized"
  vpc_zone_identifier  = [
                        "${aws_subnet.private-subnet-1.id}", 
                        "${aws_subnet.private-subnet-2.id}", 
                        "${aws_subnet.private-subnet-3.id}"
                    ]

  tag {
    key                 = "Name"
    value               = "demoEKS-Node-momory-optimized"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
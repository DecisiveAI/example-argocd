data "aws_iam_policy_document" "pod_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

# EBS CSI Driver
data "aws_iam_policy_document" "ebs_csi_web_identity_policy" {
  source_policy_documents = [data.aws_iam_policy_document.pod_assume_role_policy.json]
  statement {
    sid = "WebIdentity"

    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.ebs_csi_driver_namespace}:${var.ebs_csi_driver_sa}"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  name               = var.ebs_csi_driver_iam
  path               = "/"
  description        = "EKS EBS CSI Driver IAM Role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_web_identity_policy.json

  tags = {
    Name        = var.ebs_csi_driver_iam
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  role       = aws_iam_role.ebs_csi_driver.name
  policy_arn = var.ebs_csi_driver_policy_arn
}
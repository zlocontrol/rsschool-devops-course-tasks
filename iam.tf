
resource "aws_iam_group" "group-rolling" {
  name = var.group_name
}

locals {
  policies = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
  ]
}








resource "aws_iam_group_policy_attachment" "group-rolling" {
  for_each   = toset(local.policies)
  group      = aws_iam_group.group-rolling.name
  policy_arn = each.key
}


resource "aws_iam_user" "user-rolling" {
  name = var.iam_user_name
}

resource "aws_iam_user_group_membership" "user-rolling" {
  groups = [aws_iam_group.group-rolling.name]
  user   = aws_iam_user.user-rolling.name
}






resource "aws_iam_policy" "ssm_read_policy" {
  name        = "${var.name_prefix}-ec2-ssm-read-policy"
  description = "Allows EC2 instances to read specific SSM parameters"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:ssm:${var.aws_region}:*:parameter/${var.name_prefix}/*"
      },
      # Add this to allow EC2 to describe itself for the IAM role
      {
        Action   = "ec2:DescribeInstances",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role" "k3s_ec2_role" {
  name = "${var.name_prefix}-k3s-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "k3s_ec2_role_ssm_attach" {
  role       = aws_iam_role.k3s_ec2_role.name
  policy_arn = aws_iam_policy.ssm_read_policy.arn
}

resource "aws_iam_instance_profile" "k3s_ec2_profile" {
  name = "${var.name_prefix}-k3s-ec2-profile"
  role = aws_iam_role.k3s_ec2_role.name
}
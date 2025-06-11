
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
  user = aws_iam_user.user-rolling.name
}


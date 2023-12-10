resource "aws_iam_instance_profile" "metering_full_access_instance_profile" {
  count  = var.is_server_paygo_instance ? 1 : 0
  name   = "${var.name_prefix}-paygo-metering"

  role = aws_iam_role.metering_full_access_role.name
}

resource "aws_iam_role" "metering_full_access_role" {
  name   = "${var.name_prefix}-metering-full-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
      },
    ],
  })
}


resource "aws_iam_role_policy_attachment" "metering_full_access_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSMarketplaceMeteringFullAccess"
  role       = aws_iam_role.metering_full_access_role.name
}

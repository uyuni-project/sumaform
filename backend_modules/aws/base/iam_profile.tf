resource "aws_iam_role" "marketplace_role" {
  count = var.is_server_paygo_instance ? 1 : 0

  name = "${var.name_prefix}-paygo-metering"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "metering.marketplace.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "marketplace_policy" {
  count = var.is_server_paygo_instance ? 1 : 0

  name = "${var.name_prefix}-paygo-metering"
  description = "Policy for MeterUsage permission"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "aws-marketplace:MeterUsage",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_marketplace_policy" {
  count      = var.is_server_paygo_instance ? 1 : 0
  policy_arn = aws_iam_policy.marketplace_policy[0].arn
  role       = aws_iam_role.marketplace_role[0].name
}

resource "aws_iam_instance_profile" "test_profile" {
  count  = var.is_server_paygo_instance ? 1 : 0
  name   = "${var.name_prefix}-paygo-metering"
  role   = aws_iam_role.marketplace_role.name
}
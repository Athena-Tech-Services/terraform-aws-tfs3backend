data "aws_caller_identity" "current" {

}

locals {
  principal_arns = var.principal_arns != null ? var.principal_arns : [data.aws_caller_identity.current.arn]
}

data "aws_iam_policy_document" "tf_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = local.principal_arns
    }
  }
}

resource "aws_iam_role" "tf_role" {
  name               = "${var.project_name}-tf-role"
  tags               = local.tags
  assume_role_policy = data.aws_iam_policy_document.tf_role_assume_role_policy.json

}

data "aws_iam_policy_document" "tf_role_s3_dynamo_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tf_backend.arn]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListObjects",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.tf_backend.arn}/*"]
  }

  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [aws_dynamodb_table.dynamo_table.arn]
  }
}

resource "aws_iam_policy" "iam_policy" {
  name   = "${var.project_name}-iam-policy"
  policy = data.aws_iam_policy_document.tf_role_s3_dynamo_policy.json
}

resource "aws_iam_role_policy_attachment" "tf_role_policy_attachment" {
  role       = aws_iam_role.tf_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}
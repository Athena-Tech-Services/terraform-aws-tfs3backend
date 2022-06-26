output "config" {
  value = {
    bucket       = aws_s3_bucket.tf_backend
    region       = var.region
    role_arn     = aws_iam_role.tf_role.arn
    dynamo_table = aws_dynamodb_table.dynamo_table.name
  }
}
provider "aws" {
  region = var.region
}

resource "random_string" "rand" {
  special = false
  upper = false
  length = 8
}

locals {
    project_tag = {
        project_name = var.project_name
    }
  bucketname = "${var.project_name}-${random_string.rand.id}"
  tags = merge(local.project_tag, var.resource_tag)
  dynamo_table_name = "${var.project_name}-${random_string.rand.id}"
}

resource "aws_kms_key" "kms" {
  tags = local.tags
}

resource "aws_s3_bucket" "tf_backend" {
    bucket = local.bucketname
    tags = local.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse-config" {
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
      kms_master_key_id = aws_kms_key.kms.arn
    }
  }
  bucket = aws_s3_bucket.tf_backend.id
}

resource "aws_s3_bucket_versioning" "bucket_version" {
  bucket = aws_s3_bucket.tf_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
    bucket = aws_s3_bucket.tf_backend.id
}

resource "aws_dynamodb_table" "dynamo_table" {
  name = local.dynamo_table_name
  hash_key = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = local.tags
}
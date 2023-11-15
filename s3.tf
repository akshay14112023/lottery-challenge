locals {
  bucket_name = "lottery-data-bucket"
  staging_dir = "query-result"
}

data "http" "lottery_file" {
  url = "https://data.ny.gov/api/views/5xaw-6ayf/rows.csv?accessType=DOWNLOAD"
}


resource "aws_s3_bucket" "lottery" {
  bucket = local.bucket_name

  tags = local.tags
}

resource "aws_kms_key" "key" {
  description             = "This key is used to encrypt bucket objects in the bucket ${aws_s3_bucket.lottery.bucket}"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "kms" {
  bucket = aws_s3_bucket.lottery.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_object" "winning_numbers" {
  bucket         = aws_s3_bucket.lottery.bucket
  key            = "datasets/Lottery_Mega_Millions_Winning_Numbers__Beginning_2002.csv"
  content_base64 = sensitive(data.http.lottery_file.response_body_base64) # Made it sensitive to redule length of tf plan
  content_type   = data.http.lottery_file.response_headers["Content-Type"]
}

resource "aws_s3_object" "query_result" {
  bucket = aws_s3_bucket.lottery.bucket
  key    = "${local.staging_dir}/"
  source = "/dev/null"
}

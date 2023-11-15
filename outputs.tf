output "athena_connection_details" {
  description = "Connection details to set up Athena database in Apache Superset"
  sensitive   = true
  value = {
    SQLALCHEMY_URI = "awsathena+rest://${aws_iam_access_key.superset.id}:${aws_iam_access_key.superset.secret}@athena.${data.aws_region.current.name}.amazonaws.com/${aws_s3_bucket.lottery.bucket}?s3_staging_dir=${local.staging_dir}&work_group=${aws_athena_workgroup.superset.name}"
    ENGINE_PARAMETERS = jsonencode({
      connect_args = {
        role_arn = aws_iam_role.superset.arn
      }
    })
  }
}

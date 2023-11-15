resource "helm_release" "superset" {
  name             = "superset"
  repository       = "https://apache.github.io/superset"
  chart            = "superset"
  version          = "0.10.7" # Use app version 2.1.0 to prevent redirect/302 issues with the HTTP endpoint
  namespace        = "superset"
  create_namespace = true

  values = [
    file("${path.module}/superset-helm-values.yaml")
  ]
}

resource "aws_athena_workgroup" "superset" {
  name = "superset"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.lottery.bucket}/${local.staging_dir}/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.key.arn
      }
    }
  }
}


// Superset IAM
resource "aws_iam_role" "superset" {
  name = "superset_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_user.superset.arn # Allow the superset user to assume this role
        },
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "athena.amazonaws.com" # Allow the athena/work group to assume this role
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "athena_policy" {
  name        = "athena_policy"
  description = "Policy for full Athena access to a specified workgroup"

  policy = jsonencode({
    Version = "2012-10-17",

    # Note: A Part of the requried IAM policy is referenced from here,
    # but this is not perfect to be used in a production env
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "athena:BatchGetQueryExecution",
          "athena:GetQueryExecution",
          "athena:ListQueryExecutions",
          "athena:StartQueryExecution",
          "athena:StopQueryExecution",
          "athena:GetQueryResults",
          "athena:GetQueryResultsStream",
          "athena:CreateNamedQuery",
          "athena:GetNamedQuery",
          "athena:BatchGetNamedQuery",
          "athena:ListNamedQueries",
          "athena:DeleteNamedQuery",
          "athena:CreatePreparedStatement",
          "athena:GetPreparedStatement",
          "athena:ListPreparedStatements",
          "athena:UpdatePreparedStatement",
          "athena:DeletePreparedStatement",
        ],
        Resource = [aws_athena_workgroup.superset.arn],
      },
      {
        Effect = "Allow",
        Action = [
          "athena:DeleteWorkGroup",
          "athena:UpdateWorkGroup",
          "athena:GetWorkGroup",
          "athena:CreateWorkGroup",
        ],
        Resource = [aws_athena_workgroup.superset.arn],
      },
      {
        Effect = "Allow",
        Action = [
          "athena:ListEngineVersions",
          "athena:ListWorkGroups",
          "athena:ListDataCatalogs",
          "athena:ListDatabases",
          "athena:GetDatabase",
          "athena:ListTableMetadata",
          "athena:GetTableMetadata",
        ],
        Resource = "*",
      },
      {
        Effect = "Allow",
        Action = [
          "glue:*", # NOT recommended in a production environment; follow principle of least privilege
        ],
        Resource = "*",
      },
    ],
  })
}

resource "aws_iam_policy" "s3_policy" {
  name        = "athena_s3_policy"
  description = "Policy for Athena/Superset to query S3 bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "${aws_s3_bucket.lottery.arn}",
         "${aws_s3_bucket.lottery.arn}/*"
      ]
    },
{
      "Effect": "Allow",
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Resource": [
        "${aws_kms_key.key.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "superset_s3_policy_attachment" {
  policy_arn = aws_iam_policy.s3_policy.arn
  role       = aws_iam_role.superset.name
}

resource "aws_iam_role_policy_attachment" "superset_athena_policy_attachment" {
  policy_arn = aws_iam_policy.athena_policy.arn
  role       = aws_iam_role.superset.name
}

resource "aws_iam_user" "superset" {
  name = "superset_user"
}

resource "aws_iam_access_key" "superset" {
  user = aws_iam_user.superset.name
}

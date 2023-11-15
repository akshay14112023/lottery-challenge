resource "aws_glue_catalog_database" "s3" {
  name = "lottery_db"
}

resource "aws_glue_catalog_table" "lottery" {
  name          = "draw_details"
  database_name = aws_glue_catalog_database.s3.name
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL                 = "TRUE",
    classification           = "csv"
    "skip.header.line.count" = "1"

  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.lottery.bucket}/datasets"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "serialization.format" = "1",
        "field.delim"          = ","
      }
    }

    columns {
      name = "draw_date"
      type = "string"
    }

    columns {
      name = "winning_numbers"
      type = "string"
    }

    columns {
      name = "mega_ball"
      type = "int"
    }

    columns {
      name = "multiplier"
      type = "int"
    }
  }
}

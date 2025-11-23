# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "equity_lambda_zip" {
  type        = "zip"
  source_file = "${path.root}/../LambdaScripts/lambda_invoke_equity_glue_job.py"
  output_path = "${path.module}/build/lambda_invoke_equity_glue_job.zip"
}

resource "aws_lambda_function" "RunEquityGlueJob" {
  filename         = data.archive_file.equity_lambda_zip.output_path
  function_name    = "RunEquityGlueJob"
  handler          = "lambda_invoke_equity_glue_job.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.13"

  environment {
    variables = {
      ENVIRONMENT = "dev"
      LOG_LEVEL   = "info"
    }
  }

  tags = {
    Environment = "dev"
  }
}

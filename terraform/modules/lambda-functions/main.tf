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
  name               = "lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_glue_policy" {
  name = "lambda-glue-policy"
  description = "policy to allow aws lambda call aws glue crawler"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" = [
          "glue:StartCrawler",
          "glue:GetCrawler",
        ]
        "Effect"="Allow"
        "Resource": "arn:aws:glue:eu-central-1:538780774653:crawler/etfs-equity-crawler"
      },
      {
        "Action" = [
          "glue:StartJobRun"
        ]
        "Effect"="Allow"
        "Resource": "arn:aws:glue:eu-central-1:538780774653:job/EquityDataPreparation"
      },
      {
        "Effect" = "Allow"
        "Action" = [
          "lambda:InvokeFunction"
        ]
        "Resource" = "arn:aws:lambda:eu-central-1:538780774653:function:RunEquityGlueJob"
      },
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
		  }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachement" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_glue_policy.arn
}

#######################################################
# Definition of lambda functions resources for aws glue
#######################################################
data "archive_file" "equity_lambda_crawler_zip" {
  type        = "zip"
  source_file = "${path.root}/../LambdaScripts/lambda_run_glue_crawler.py"
  output_path = "${path.module}/build/lambda_run_glue_crawler.zip"
}

data "archive_file" "equity_lambda_zip_job" {
  type        = "zip"
  source_file = "${path.root}/../LambdaScripts/lambda_run_glue_job.py"
  output_path = "${path.module}/build/lambda_run_glue_job.zip"
}

resource "aws_lambda_function" "RunEquityGlueCrawler" {
  filename         = data.archive_file.equity_lambda_crawler_zip.output_path
  function_name    = "RunEquityGlueCrawler"
  handler          = "lambda_run_glue_crawler.lambda_handler"
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

resource "aws_lambda_function" "RunEquityGlueJob" {
  filename         = data.archive_file.equity_lambda_zip_job.output_path
  function_name    = "RunEquityGlueJob"
  handler          = "lambda_run_glue_job.lambda_handler"
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

######################################################
# Lambda function for starting step functions workflow
######################################################

resource "aws_iam_role" "lambda_step_functions_role" {
  name = "call-step-functions-workflow"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Environment = "dev"
  }
}

resource "aws_iam_policy" "lambda_step_functions_policy" {
  name        = "lambda_step_functions_policy"
  description = "Policy that will allow lambda function call step functions workflow."

  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sf_policy_attachement" {
  role = aws_iam_role.lambda_step_functions_role.name
  policy_arn = aws_iam_policy.lambda_step_functions_policy.arn
}

data "archive_file" "step_function_lambda" {
  type        = "zip"
  source_file = "${path.root}/../LambdaScripts/lambda_run_sf_workflow.py"
  output_path = "${path.module}/build/lambda_run_sf_workflow.zip"
}

resource "aws_lambda_function" "RunStepFunctionWorkflow" {
  filename = data.archive_file.step_function_lambda.output_path
  function_name = "RunStepFunctionWorkflow"
  handler = "lambda_run_step_function_workflow.lambda_handler"
  role = aws_iam_role.lambda_step_functions_role.arn
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
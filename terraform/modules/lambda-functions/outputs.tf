output "lambda_glue_job_arn" {
  description = "ARN value of the lambda function used to trigger Glue job"
  value = aws_lambda_function.RunEquityGlueJob.arn
}

output "lambda_glue_crawler_arn" {
  description = "ARN value of the lambda function used to trigger crawler"
  value = aws_lambda_function.RunEquityGlueCrawler.arn
}

output "lambda_sf_workflow_arn" {
  description = "ARN value of the lambda function used to start sf workflow"
  value = aws_lambda_function.RunStepFunctionWorkflow.arn
}
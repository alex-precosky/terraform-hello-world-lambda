terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.25.0"
    }
  }

  required_version = ">= 1.6.3"
}

provider "aws" {
  region = "us-west-2"
}

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

resource "aws_iam_role" "lambda_service_role" {
  name               = "lambda_service_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "hello_world_lambda_zipfile" {
  type        = "zip"
  source_file = "function/hello_world_lambda.py"
  output_path = "hello_world_lambda_payload.zip"
}

resource "aws_lambda_function" "hello_world_lambda" {
  filename      = "hello_world_lambda_payload.zip"
  function_name = "hello_world_lambda"
  role          = aws_iam_role.lambda_service_role.arn
  handler       = "hello_world_lambda.lambda_handler"

  source_code_hash = data.archive_file.hello_world_lambda_zipfile.output_base64sha256

  runtime = "python3.10"
}

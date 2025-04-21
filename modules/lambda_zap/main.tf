data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "zap_lambda" {
  # source  = "terraform-aws-modules/lambda/aws"
  # version = "~> 7.0"

  function_name = "zap-dast"
  package_type  = "Image"
  image_uri     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/zap-lambda:${var.env_name}"
  # image_uri = "dummy-uri"

  memory_size = 1024
  timeout     = 900

  environment {
    variables = {
      TARGET_URL    = var.target_url
      REPORT_BUCKET = var.bucket_name
    }
  }

  role = aws_iam_role.lambda_exec.arn

  tags = merge(var.common_tags, {
    "purpose" = "Run OWASP ZAP DAST scans"
  })
}

############################################################
# IAM role + policy for Lambda
############################################################
resource "aws_iam_role" "lambda_exec" {
  name               = "zap-dast-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = var.common_tags
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "lambda_inline" {
  name   = "zap-dast-inline"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_inline.json
}

data "aws_iam_policy_document" "lambda_inline" {
  statement {
    sid    = "WriteReports"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${var.bucket_arn}/*"
    ]
  }

  statement {
    sid       = "AllowLogs"
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

############################################################
# CloudWatch Events – scheduled daily scan
############################################################
resource "aws_cloudwatch_event_rule" "daily" {
  name                = "zap-daily"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "zap_lambda" {
  rule      = aws_cloudwatch_event_rule.daily.name
  target_id = "lambda"
  arn       = aws_lambda_function.zap_lambda.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.zap_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily.arn
}

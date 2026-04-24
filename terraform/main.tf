resource "aws_iam_role" "lambda_role" {
  name = "lambda-basic-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "hello_lambda" {
  function_name = "hello-lambda"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "app.lambda_handler"
  runtime = "python3.11"

  role = aws_iam_role.lambda_role.arn
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "dev-deploy-bucket-1"

  tags = {
    Name        = "lambda-deploy-bucket"
    Environment = "dev"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/hello_lambda"
  output_path = "${path.module}/lambda.zip"
}
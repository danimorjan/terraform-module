

resource "aws_s3_bucket" "this" {
  bucket = "onlie-shop-frontend"
  tags = {
    Name        = "TF Frontend shop"
    Environment = "Test"
  }

}
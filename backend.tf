terraform {
  backend "s3" {
    bucket = "tf-bz-2025"
    key    = "key1/tf-bz-2025"
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "audit_logs" {
  provider      = aws.audit
  bucket        = "enterprise-landing-zone-logs-${aws_organizations_account.audit.id}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_cloudtrail" {
  provider = aws.audit
  bucket   = aws_s3_bucket.audit_logs.id
  policy   = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.audit_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.audit_logs.arn}/AWSLogs/${aws_organizations_organization.org.id}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      },
      {
        Sid    = "AWSCloudTrailGetLocation"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:GetBucketLocation"
        Resource = aws_s3_bucket.audit_logs.arn
      }
    ]
  })
}

resource "aws_cloudtrail" "organization_trail" {
  # We add a sleep timer indirectly by ensuring the policy is 100% there
  depends_on = [aws_s3_bucket_policy.allow_cloudtrail]
  
  name                          = "org-wide-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_logging                = true
}
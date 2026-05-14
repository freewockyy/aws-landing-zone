# 1. Management Account Detector
resource "aws_guardduty_detector" "main" {
  enable = true
}

# 2. Delegate the Audit Account
resource "aws_guardduty_organization_admin_account" "gd_admin" {
  depends_on       = [aws_guardduty_detector.main]
  admin_account_id = aws_organizations_account.audit.id
}

# 3. Org-wide Configuration
resource "aws_guardduty_organization_configuration" "gd_config" {
  # We wait for the admin delegation to "settle"
  depends_on = [aws_guardduty_organization_admin_account.gd_admin]
  
  auto_enable_organization_members = "ALL"
  detector_id                      = aws_guardduty_detector.main.id
}
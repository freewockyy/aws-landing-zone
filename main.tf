provider "aws" {
  region = "us-east-1"
}

#provides a special provider for the audit account
provider "aws" {
  alias  = "audit"
  region = "us-east-1"
  assume_role {
    # This role is created automatically by AWS when Terraform creates the account
    role_arn = "arn:aws:iam::${aws_organizations_account.audit.id}:role/OrganizationAccountAccessRole"
  }
}
# 1. Initialize the Organization
resource "aws_organizations_organization" "org" {
  feature_set = "ALL"
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]

  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "guardduty.amazonaws.com"
  ]
}

# 2. Create OUs for grouping
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_organizational_unit" "workload" {
  name      = "Workload"
  parent_id = aws_organizations_organization.org.roots[0].id
}

# 3. Create the Audit Account inside Security OU
resource "aws_organizations_account" "audit" {
  name      = "Audit-Account"
  email     = "temp+audit@gmail.com"
  parent_id = aws_organizations_organizational_unit.security.id
}

# 4. Create the Sandbox Account inside Workload OU
resource "aws_organizations_account" "sandbox" {
  name      = "Sandbox-Account"
  email     = "temp+sandbox@gmail.com" 
  parent_id = aws_organizations_organizational_unit.workload.id

  #close accounts fully upon removal
  close_on_deletion = true
}
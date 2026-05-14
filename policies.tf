resource "aws_organizations_policy" "deny_stop_logging" {
    name    = "DenyStopLogging"
    description = "Prevents users from disabling CloudTrail"
    type    = "SERVICE_CONTROL_POLICY"

    content = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect  = "Deny"   
                Action  = [
                    "cloudtrail:StopLogging",
                    "cloudtrail:DeleteTrail"
                ]
                Resource = "*"
            }
        ]
    })
}

#gets attached to workload OU
resource "aws_organizations_policy_attachment" "workload_guardrail" {
  policy_id = aws_organizations_policy.deny_stop_logging.id
  target_id = aws_organizations_organizational_unit.workload.id
}
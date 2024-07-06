resource "aws_guardduty_detector" "main" {
  enable = true
}

resource "aws_guardduty_member" "main" {
  account_id         = data.aws_caller_identity.current
  detector_id        = aws_guardduty_detector.main.id
  email              = var.email
  invitation_message = "please accept AWS GuardDuty invitation"
}

data "template_file" "instance_profile" {
  count    = var.enable_cloudwatch_logging ? 1 : 0
  template = file("${path.module}/policies/instance-logging-policy.json")

}

data "template_file" "logging" {
  template = file("${path.module}/template/logging.tpl")

  vars = {
    log_group_name = var.log_group_name != null ? var.log_group_name : var.environment
  }
}

resource "aws_iam_role_policy" "instance" {
  count  = var.enable_cloudwatch_logging ? 1 : 0
  name   = "${var.environment}-instance-role"
  role   = aws_iam_role.instance.name
  policy = data.template_file.instance_profile[0].rendered
}


locals {
  provided_kms_key = var.kms_key_id != "" ? var.kms_key_id : ""
  kms_key          = local.provided_kms_key == "" && var.enable_kms ? aws_kms_key.default[0].arn : local.provided_kms_key
}

resource "aws_cloudwatch_log_group" "environment" {
  count             = var.enable_cloudwatch_logging ? 1 : 0
  name              = var.environment
  retention_in_days = var.cloudwatch_logging_retention_in_days
  tags              = local.tags
  kms_key_id        = local.kms_key
}

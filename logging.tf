resource "aws_iam_role_policy" "instance" {
  count  = var.enable_cloudwatch_logging && var.create_runner_iam_role ? 1 : 0
  name   = "${local.name_iam_objects}-logging"
  role   = var.create_runner_iam_role ? data.aws_iam_role.instance.name : local.aws_iam_role_instance_name
  policy = templatefile("${path.module}/policies/instance-logging-policy.json", { partition = data.aws_partition.current.partition })
}

locals {
  logging_user_data = templatefile("${path.module}/template/logging.tftpl",
    {
      log_group_name = var.log_group_name != null ? var.log_group_name : var.environment
      http_proxy     = var.http_proxy
      https_proxy    = var.https_proxy
  })
  provided_kms_key = var.kms_key_id != "" ? var.kms_key_id : ""
  kms_key          = local.provided_kms_key == "" && var.enable_kms ? aws_kms_key.default[0].arn : local.provided_kms_key
}


# We dont want this to be part of the state file as it breaks during destroy with nodes writing to it, so we've set it count 0 here.
resource "aws_cloudwatch_log_group" "environment" {
  count             = 0
  name              = var.log_group_name != null ? var.log_group_name : var.environment
  retention_in_days = var.cloudwatch_logging_retention_in_days
  tags              = local.tags

  # ignored as decided by the user
  # tfsec:ignore:aws-cloudwatch-log-group-customer-key
  # checkov:skip=CKV_AWS_158:Encryption can be enabled by user
  kms_key_id = local.kms_key
}

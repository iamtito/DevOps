#####################################################
## Description: All healthcheck follows this module to avoid repeatition
## Usaged:
##            module "CVKH-Legacy" {
##                source     = "PathToThisFile"
##                fqdn       = "example.com"
##                name       = "Check Name"
##                alarm_name = "Check Name Health Check Status"
##            }
## To use any value other than the default value, parse it along the block,
## e.g to use a different port, specify a resource path other than the default,
## You can use the below
##            module "CVKH-Legacy" {
##                source         = "PathToThisFile"
##                fqdn           = "example.com"
##                name           = "Check Name"
##                port           = "80"
##                resource_path  = "/sumit/su.php?mit_id=11"
##                alarm_name = "Check Name Health Check Status"
##            }
#####################################################
resource "aws_route53_health_check" "healthcheck" {
  fqdn              = "${var.fqdn}"
  port              = "${var.port}"
  type              = "${var.type}"
  resource_path     = "${var.resource_path}"
  failure_threshold = "1"
  request_interval  = "30"
  enable_sni        = "${var.enable_sni}"
  measure_latency   = true

  tags = {
    Name = "${var.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "healthcheck" {
  alarm_name          = "${var.alarm_name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "This metric monitors route 53 healthchecks"
  alarm_actions       = ["${data.aws_sns_topic.external-critical.arn}"]

  dimensions {
    HealthCheckId = "${aws_route53_health_check.healthcheck.id}"
  }
}

data "aws_sns_topic" "external-critical" {
  name = "${var.sns}"
}

output "resource_created" {
  value = ["${aws_route53_health_check.healthcheck.id}"]
}

variable "enable_sni" {
  default = true
}

variable "port" {
  default = 443
}

variable "type" {
  default = "HTTPS"
}

variable "sns" {
  default = "CriticalAlerts"
}

variable "fqdn" {
  default = ""
}

variable "name" {
  default = ""
}

variable "alarm_name" {
  default = ""
}

variable "resource_path" {
  default = "/"
}

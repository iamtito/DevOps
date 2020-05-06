Terraform module which creates ALB resources on AWS.

Description
-----------
Provision ALB, ALB Listeners, Target Groups, ALB S3 bucket and Cloudwatch Alarm.

This module provides recommended settings:

* Listener
* Target Group
* Enable Access Logging
* Enable HTTP to HTTPS redirect
* Use AWS recommended SSL Policy
* Cloudwatch Alarms

Default Settings
-----
* All cloudwatch alarms are turned on by defaul to turn of, set `enable_NAME_OF_ALARM = "no"`
* Target group default settings 
```
    cookie_duration                  = 86400
    deregistration_delay             = 300
    health_check_interval            = 30
    health_check_healthy_threshold   = 5
    health_check_path                = "/"
    health_check_port                = "traffic-port"
    health_check_timeout             = 5
    health_check_unhealthy_threshold = 2
    health_check_matcher             = "200"
    stickiness_enabled               = false
    target_type                      = "instance"
    slow_start                       = 0
```
* Subnet is prod by default 
* default `idle_timeout=60` 
* default tag is `Name=NAME OF ALB` and You can expand on the tag if you want to, e.g:
```
  tags = {
    "Env" = "Prod",
    "App" = "Test App",
    "AppGroup" = "Test group"
  }
```
* Default SSL Policy is `ELBSecurityPolicy-TLS-1-1-2017-01`. To change set `ssl_policy_default=YOUR DESIRED POLICY`
* Default VPC is production
* Default SNS Topic is `ExternalCriticalAlerts`, to switch set `sns_topic=YOUR DESIRED TOPIC`
* Cloudwatch alarms default settings
   * `alb_surge_threshold = "10"`
   * `alb_alb500_threshold = "5"`
   * `alb_http500_backend_threshold = "5"`
   * `alb_http400_threshold = "10"`
   * `alb_http400count_threshold = "10"`
   * `alb_http400_target_threshold = "10"`
   * `enable_alb_http400 = "yes"`
   * `enable_alb_http400_target = "yes"`
   * `enable_alb_http400count = "yes"`
   * `enable_alb_http500 = "yes"`
   * `enable_alb_alb500 = "yes"`
   * `enable_alb_surge = "yes"`
   * `enable_alb_unhealthy_target1 = "yes"`
   * `enable_alb_unhealthy_target2 = "yes"`

Usage
-----
**Full Feature Usage Sample**
```
provider "aws" {
  region                  = "us-east-1"
  profile                 = "default"
}

module "stage" {
  source            = "../../../global/modules/alb"
  alb_name          = "theTEST"
  security_groups   = ["sg-xxxxx","sg-xxxx"]
  subnet_tag           = "prod"
  access_logs_enabled = true
  route_53_zone     = "example.com"
  lb_dns_name       = "testingalb"
  tags = {
    "Env" = "Prod"
  }
  alb_listeners = [
    {
      "port"            = 80
      "protocol"        = "HTTP"
    },
    {
      "certificate_arn"    = "arn:aws:acm:us-east-1:157586424155:certificate/d6xxxxxxxxxxxxx"
      "port"               = 443
      "ssl_policy"         = "ELBSecurityPolicy-2016-08"
      "target_group_index" = 1
      "protocol"           = "https"
    },
  ]
  target_groups = [
    {
      "name"             = "tarport"
      "backend_protocol" = "HTTP"
      "backend_port"     = 80
      "slow_start"       = 0
    },
    {
      "name"             = "tarportTests"
      "backend_protocol" = "HTTPS"
      "backend_port"     = 445
    },
  ]

}
```



OUTPUT:
```
$ terraform apply 
module.stage.data.aws_sns_topic.sns_topic: Refreshing state...
module.stage.data.aws_vpc.prod: Refreshing state...
module.stage.module.s3log.module.route53.data.aws_route53_zone.route53-zone: Refreshing state...
module.stage.data.aws_route53_zone.route53-zone: Refreshing state...
module.stage.data.aws_subnet_ids.all: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.stage.aws_cloudwatch_metric_alarm.alb-surge[0] will be created
  + resource "aws_cloudwatch_metric_alarm" "alb-surge" {
      + actions_enabled                       = true
      + alarm_actions                         = [
          + "arn:aws:sns:us-east-1:157586424155:ExternalCriticalAlerts",
        ]
      + alarm_description                     = "This metric monitors the theTEST ALB - Surge Queue Length"
      + alarm_name                            = "[AWS ALB - theTEST] Surge Queue Length Above Threshold (10)"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 5
      + id                                    = (known after apply)
      + metric_name                           = "SurgeQueueLength"
      + namespace                             = "AWS/ApplicationELB"
      + period                                = 60
      + statistic                             = "Sum"
      + threshold                             = 10
      + treat_missing_data                    = "notBreaching"
    }

  # module.stage.aws_cloudwatch_metric_alarm.alb_alb500[0] will be created
  + resource "aws_cloudwatch_metric_alarm" "alb_alb500" {
      + actions_enabled                       = true
      + alarm_actions                         = [
          + "arn:aws:sns:us-east-1:157586424155:ExternalCriticalAlerts",
        ]
      + alarm_description                     = "This metric monitors the theTEST ALB - ALB HTTP 500s"
      + alarm_name                            = "[AWS ALB - theTEST] ALB HTTP Status 500s above threshold (5)"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 5
      + id                                    = (known after apply)
      + metric_name                           = "HTTPCode_alb_5XX"
      + namespace                             = "AWS/ApplicationELB"
      + period                                = 60
      + statistic                             = "Sum"
      + threshold                             = 5
      + treat_missing_data                    = "notBreaching"
    }

  # module.stage.aws_cloudwatch_metric_alarm.alb_http400[0] will be created
  + resource "aws_cloudwatch_metric_alarm" "alb_http400" {
      + actions_enabled                       = true
      + alarm_actions                         = [
          + "arn:aws:sns:us-east-1:157586424155:ExternalCriticalAlerts",
        ]
      + alarm_description                     = "This metric monitors the theTEST ALB - HTTP 400s"
      + alarm_name                            = "[AWS ALB - theTEST] Backend HTTP Status 400s above threshold (10)"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 5
      + id                                    = (known after apply)
      + metric_name                           = "HTTPCode_Backend_4XX"
      + namespace                             = "AWS/ApplicationELB"
      + period                                = 60
      + statistic                             = "Sum"
      + threshold                             = 10
      + treat_missing_data                    = "notBreaching"
    }

  # module.stage.aws_cloudwatch_metric_alarm.alb_http400_target[0] will be created
  + resource "aws_cloudwatch_metric_alarm" "alb_http400_target" {
      + actions_enabled                       = true
      + alarm_actions                         = [
          + "arn:aws:sns:us-east-1:157586424155:ExternalCriticalAlerts",
        ]
      + alarm_description                     = "This metric monitors the theTEST ALB - HTTP 400s"
      + alarm_name                            = "[AWS ALB - theTEST] Backend Target HTTP Status 400s above threshold (10)"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 5
      + id                                    = (known after apply)
      + metric_name                           = "HTTPCode_Target_4XX_Count"
      + namespace                             = "AWS/ApplicationELB"
      + period                                = 60
      + statistic                             = "Sum"
      + threshold                             = 10
      + treat_missing_data                    = "notBreaching"
    }

  # module.stage.aws_cloudwatch_metric_alarm.alb_http400count[0] will be created
  + resource "aws_cloudwatch_metric_alarm" "alb_http400count" {
      + actions_enabled                       = true
      + alarm_actions                         = [
          + "arn:aws:sns:us-east-1:157586424155:ExternalCriticalAlerts",
        ]
      + alarm_description                     = "This metric monitors the theTEST ALB - HTTP 400s"
      + alarm_name                            = "[AWS ALB - theTEST] HTTP Status 400s Count above threshold (10)"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 5
      + id                                    = (known after apply)
      + metric_name                           = "HTTPCode_ELB_4XX_Count"
      + namespace                             = "AWS/ApplicationELB"
      + period                                = 60
      + statistic                             = "Average"
      + threshold                             = 10
      + treat_missing_data                    = "notBreaching"
    }

  # module.stage.aws_cloudwatch_metric_alarm.alb_http500[0] will be created
  + resource "aws_cloudwatch_metric_alarm" "alb_http500" {
      + actions_enabled                       = true
      + alarm_actions                         = [
          + "arn:aws:sns:us-east-1:157586424155:ExternalCriticalAlerts",
        ]
      + alarm_description                     = "This metric monitors the theTEST - HTTP 500s"
      + alarm_name                            = "[AWS ALB - theTEST] Backend HTTP Status 500s above threshold (5)"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 5
      + id                                    = (known after apply)
      + metric_name                           = "HTTPCode_Backend_5XX"
      + namespace                             = "AWS/ApplicationELB"
      + period                                = 60
      + statistic                             = "Sum"
      + threshold                             = 5
      + treat_missing_data                    = "notBreaching"
    }

  # module.stage.aws_cloudwatch_metric_alarm.alb_unhealthy_target1[0] will be created
  + resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_target1" {
      + actions_enabled                       = true
      + alarm_actions                         = [
          + "arn:aws:sns:us-east-1:157586424155:ExternalCriticalAlerts",
        ]
      + alarm_description                     = "This metric monitors the theTEST ALB - Unhealthy Hosts on tarport"
      + alarm_name                            = "[AWS ALB - theTEST] Unhealthy Hosts Exist on tarport"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 1
      + id                                    = (known after apply)
      + metric_name                           = "UnHealthyHostCount"
      + namespace                             = "AWS/ApplicationELB"
      + ok_actions                            = [
          + "arn:aws:sns:us-east-1:157586424155:ExternalCriticalAlerts",
        ]
      + period                                = 60
      + statistic                             = "Maximum"
      + threshold                             = 0
      + treat_missing_data                    = "missing"
    }

  # module.stage.aws_cloudwatch_metric_alarm.alb_unhealthy_target2[0] will be created
  + resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_target2" {
      + actions_enabled                       = true
      + alarm_actions                         = [
          + "arn:aws:sns:us-east-1:157586424155:ExternalCriticalAlerts",
        ]
      + alarm_description                     = "This metric monitors the theTEST ALB - Unhealthy Hosts on tarportTests"
      + alarm_name                            = "[AWS ALB - theTEST] Unhealthy Hosts Exist on tarportTests"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 1
      + id                                    = (known after apply)
      + metric_name                           = "UnHealthyHostCount"
      + namespace                             = "AWS/ApplicationELB"
      + ok_actions                            = [
          + "arn:aws:sns:us-east-1:157586424155:ExternalCriticalAlerts",
        ]
      + period                                = 60
      + statistic                             = "Maximum"
      + threshold                             = 0
      + treat_missing_data                    = "missing"
    }

  # module.stage.aws_lb.default[0] will be created
  + resource "aws_lb" "default" {
      + arn                        = (known after apply)
      + arn_suffix                 = (known after apply)
      + dns_name                   = (known after apply)
      + enable_deletion_protection = false
      + enable_http2               = true
      + id                         = (known after apply)
      + idle_timeout               = 60
      + internal                   = false
      + ip_address_type            = (known after apply)
      + load_balancer_type         = "application"
      + name                       = "theTEST"
      + security_groups            = [
          + "sg-0c076144",
          + "sg-18e1fc63",
        ]
      + subnets                    = [
          + "subnet-71f20528",
          + "subnet-8f763183",
          + "subnet-9a2235b2",
          + "subnet-b271b6d6",
          + "subnet-bd759282",
          + "subnet-ecfc299b",
        ]
      + tags                       = {
          + "Env"  = "Prod"
          + "Name" = "theTEST"
        }
      + vpc_id                     = (known after apply)
      + zone_id                    = (known after apply)

      + access_logs {
          + bucket  = (known after apply)
          + enabled = true
          + prefix  = "true"
        }

      + subnet_mapping {
          + allocation_id = (known after apply)
          + subnet_id     = (known after apply)
        }
    }

  # module.stage.aws_lb_listener.default[0] will be created
  + resource "aws_lb_listener" "default" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 80
      + protocol          = "HTTP"
      + ssl_policy        = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # module.stage.aws_lb_listener.default[1] will be created
  + resource "aws_lb_listener" "default" {
      + arn               = (known after apply)
      + certificate_arn   = "arn:aws:acm:us-east-1:157586424155:certificate/d6316a42-44f1-464a-9f49-f8f3a710f182"
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 443
      + protocol          = "HTTPS"
      + ssl_policy        = "ELBSecurityPolicy-2016-08"

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # module.stage.aws_lb_target_group.default[0] will be created
  + resource "aws_lb_target_group" "default" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + deregistration_delay               = 300
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + name                               = "tarport"
      + port                               = 80
      + protocol                           = "HTTP"
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags                               = {
          + "Env"  = "Prod"
          + "Name" = "tarport"
        }
      + target_type                        = "instance"
      + vpc_id                             = "vpc-a652e7c3"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 5
          + interval            = 30
          + matcher             = "200"
          + path                = "/"
          + port                = "traffic-port"
          + protocol            = "HTTP"
          + timeout             = 5
          + unhealthy_threshold = 2
        }

      + stickiness {
          + cookie_duration = 86400
          + enabled         = false
          + type            = "lb_cookie"
        }
    }

  # module.stage.aws_lb_target_group.default[1] will be created
  + resource "aws_lb_target_group" "default" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + deregistration_delay               = 300
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + name                               = "tarportTests"
      + port                               = 445
      + protocol                           = "HTTPS"
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags                               = {
          + "Env"  = "Prod"
          + "Name" = "tarportTests"
        }
      + target_type                        = "instance"
      + vpc_id                             = "vpc-a652e7c3"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 5
          + interval            = 30
          + matcher             = "200"
          + path                = "/"
          + port                = "traffic-port"
          + protocol            = "HTTPS"
          + timeout             = 5
          + unhealthy_threshold = 2
        }

      + stickiness {
          + cookie_duration = 86400
          + enabled         = false
          + type            = "lb_cookie"
        }
    }

  # module.stage.aws_route53_record.lb_dns[0] will be created
  + resource "aws_route53_record" "lb_dns" {
      + allow_overwrite = (known after apply)
      + fqdn            = (known after apply)
      + id              = (known after apply)
      + name            = "testingalb"
      + type            = "A"
      + zone_id         = "Z20ZSFHL7WCL1U"

      + alias {
          + evaluate_target_health = false
          + name                   = (known after apply)
          + zone_id                = (known after apply)
        }
    }

  # module.stage.module.s3log.aws_s3_bucket.alb[0] will be created
  + resource "aws_s3_bucket" "alb" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "aws.alb.thetest.accesslogs"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + policy                      = jsonencode(
            {
              + Id        = "AWSConsole-AccessLogs-Policy-1573245155971"
              + Statement = [
                  + {
                      + Action    = "s3:PutObject"
                      + Effect    = "Allow"
                      + Principal = {
                          + AWS = "arn:aws:iam::127311923021:root"
                        }
                      + Resource  = "arn:aws:s3:::aws.alb.thetest.accesslogs/*"
                      + Sid       = "AWSConsoleStmt-1573245155971"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + server_side_encryption_configuration {
          + rule {
              + apply_server_side_encryption_by_default {
                  + sse_algorithm = "AES256"
                }
            }
        }

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

Plan: 15 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

module.stage.module.s3log.aws_s3_bucket.alb[0]: Creating...
module.stage.module.s3log.aws_s3_bucket.alb[0]: Creation complete after 4s [id=aws.alb.thetest.accesslogs]
module.stage.aws_lb.default[0]: Creating...
module.stage.aws_lb.default[0]: Still creating... [10s elapsed]
module.stage.aws_lb.default[0]: Still creating... [20s elapsed]
module.stage.aws_lb.default[0]: Still creating... [30s elapsed]
module.stage.aws_lb.default[0]: Still creating... [40s elapsed]
module.stage.aws_lb.default[0]: Still creating... [50s elapsed]
module.stage.aws_lb.default[0]: Still creating... [1m0s elapsed]
module.stage.aws_lb.default[0]: Still creating... [1m10s elapsed]
module.stage.aws_lb.default[0]: Still creating... [1m20s elapsed]
module.stage.aws_lb.default[0]: Still creating... [1m30s elapsed]
module.stage.aws_lb.default[0]: Still creating... [1m40s elapsed]
module.stage.aws_lb.default[0]: Still creating... [1m50s elapsed]
module.stage.aws_lb.default[0]: Still creating... [2m0s elapsed]
module.stage.aws_lb.default[0]: Still creating... [2m10s elapsed]
module.stage.aws_lb.default[0]: Still creating... [2m20s elapsed]
module.stage.aws_lb.default[0]: Still creating... [2m30s elapsed]
module.stage.aws_lb.default[0]: Still creating... [2m40s elapsed]
module.stage.aws_lb.default[0]: Still creating... [2m50s elapsed]
module.stage.aws_lb.default[0]: Still creating... [3m0s elapsed]
module.stage.aws_lb.default[0]: Still creating... [3m10s elapsed]
module.stage.aws_lb.default[0]: Creation complete after 3m16s [id=arn:aws:elasticloadbalancing:us-east-1:157586424155:loadbalancer/app/theTEST/daab04f7ae12cd2f]
module.stage.aws_cloudwatch_metric_alarm.alb-surge[0]: Creating...
module.stage.aws_cloudwatch_metric_alarm.alb_http500[0]: Creating...
module.stage.aws_cloudwatch_metric_alarm.alb_http400_target[0]: Creating...
module.stage.aws_cloudwatch_metric_alarm.alb_http400[0]: Creating...
module.stage.aws_cloudwatch_metric_alarm.alb_alb500[0]: Creating...
module.stage.aws_cloudwatch_metric_alarm.alb_http400count[0]: Creating...
module.stage.aws_lb_target_group.default[1]: Creating...
module.stage.aws_lb_target_group.default[0]: Creating...
module.stage.aws_cloudwatch_metric_alarm.alb_http400[0]: Creation complete after 1s [id=[AWS ALB - theTEST] Backend HTTP Status 400s above threshold (10)]
module.stage.aws_cloudwatch_metric_alarm.alb_http500[0]: Creation complete after 1s [id=[AWS ALB - theTEST] Backend HTTP Status 500s above threshold (5)]
module.stage.aws_cloudwatch_metric_alarm.alb_http400_target[0]: Creation complete after 1s [id=[AWS ALB - theTEST] Backend Target HTTP Status 400s above threshold (10)]
module.stage.aws_cloudwatch_metric_alarm.alb_alb500[0]: Creation complete after 1s [id=[AWS ALB - theTEST] ALB HTTP Status 500s above threshold (5)]
module.stage.aws_cloudwatch_metric_alarm.alb_http400count[0]: Creation complete after 1s [id=[AWS ALB - theTEST] HTTP Status 400s Count above threshold (10)]
module.stage.aws_cloudwatch_metric_alarm.alb-surge[0]: Creation complete after 1s [id=[AWS ALB - theTEST] Surge Queue Length Above Threshold (10)]
module.stage.aws_lb_target_group.default[0]: Creation complete after 2s [id=arn:aws:elasticloadbalancing:us-east-1:157586424155:targetgroup/tarport/2084a8eb86968e6c]
module.stage.aws_cloudwatch_metric_alarm.alb_unhealthy_target1[0]: Creating...
module.stage.aws_lb_target_group.default[1]: Creation complete after 2s [id=arn:aws:elasticloadbalancing:us-east-1:157586424155:targetgroup/tarportTests/599e17135b9ba193]
module.stage.aws_cloudwatch_metric_alarm.alb_unhealthy_target2[0]: Creating...
module.stage.aws_lb_listener.default[1]: Creating...
module.stage.aws_lb_listener.default[0]: Creating...
module.stage.aws_lb_listener.default[0]: Creation complete after 0s [id=arn:aws:elasticloadbalancing:us-east-1:157586424155:listener/app/theTEST/daab04f7ae12cd2f/fc68b41d9fb849ed]
module.stage.aws_cloudwatch_metric_alarm.alb_unhealthy_target1[0]: Creation complete after 0s [id=[AWS ALB - theTEST] Unhealthy Hosts Exist on tarport]
module.stage.aws_cloudwatch_metric_alarm.alb_unhealthy_target2[0]: Creation complete after 0s [id=[AWS ALB - theTEST] Unhealthy Hosts Exist on tarportTests]
module.stage.aws_lb_listener.default[1]: Creation complete after 1s [id=arn:aws:elasticloadbalancing:us-east-1:157586424155:listener/app/theTEST/daab04f7ae12cd2f/af06633b95caee07]
module.stage.aws_route53_record.lb_dns[0]: Creating...
module.stage.aws_route53_record.lb_dns[0]: Still creating... [10s elapsed]
module.stage.aws_route53_record.lb_dns[0]: Still creating... [20s elapsed]
module.stage.aws_route53_record.lb_dns[0]: Still creating... [30s elapsed]
module.stage.aws_route53_record.lb_dns[0]: Creation complete after 32s [id=Z20ZSFHL7WCL1U_testingalb_A]

Apply complete! Resources: 15 added, 0 changed, 0 destroyed.
$ terraform state list
module.stage.data.aws_route53_zone.route53-zone
module.stage.data.aws_sns_topic.sns_topic
module.stage.data.aws_subnet_ids.all
module.stage.data.aws_vpc.prod
module.stage.aws_cloudwatch_metric_alarm.alb-surge[0]
module.stage.aws_cloudwatch_metric_alarm.alb_alb500[0]
module.stage.aws_cloudwatch_metric_alarm.alb_http400[0]
module.stage.aws_cloudwatch_metric_alarm.alb_http400_target[0]
module.stage.aws_cloudwatch_metric_alarm.alb_http400count[0]
module.stage.aws_cloudwatch_metric_alarm.alb_http500[0]
module.stage.aws_cloudwatch_metric_alarm.alb_unhealthy_target1[0]
module.stage.aws_cloudwatch_metric_alarm.alb_unhealthy_target2[0]
module.stage.aws_lb.default[0]
module.stage.aws_lb_listener.default[0]
module.stage.aws_lb_listener.default[1]
module.stage.aws_lb_target_group.default[0]
module.stage.aws_lb_target_group.default[1]
module.stage.aws_route53_record.lb_dns[0]
module.stage.module.s3log.aws_s3_bucket.alb[0]
module.stage.module.s3log.module.route53.data.aws_route53_zone.route53-zone

```


-----
**Minimal**
```
module "s3log" {
  source       = "../../../global/modules/s3"
  enable_alb   = true
  alb_dns_name = "s3buckettest"
}

module "stage" {
  source            = "../../../global/modules/alb"
  enabled           = true
  alb_name          = "ALBTEST"
  security_groups   = ["sg-0c076144","sg-18e1fc63"]
  subnets           = ["subnet-71f20528","subnet-8f763183"]
  access_logs_bucket = module.s3log.alb_bucket_id
  certificate_arn   = "arn:aws:acm:us-east-1:157586424155:certificate/d6316a42-44f1-464a-9f49-f8f3a710f182"
}
```

**OUTPUT**
```
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

module.s3log.aws_s3_bucket.alb[0]: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.s3log.aws_s3_bucket.alb[0] will be created
  + resource "aws_s3_bucket" "alb" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "aws.alb.s3buckettest.accesslogs"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = true
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + server_side_encryption_configuration {
          + rule {
              + apply_server_side_encryption_by_default {
                  + sse_algorithm = "AES256"
                }
            }
        }

      + versioning {
          + enabled    = (known after apply)
          + mfa_delete = (known after apply)
        }
    }

  # module.stage.aws_lb.default[0] will be created
  + resource "aws_lb" "default" {
      + arn                        = (known after apply)
      + arn_suffix                 = (known after apply)
      + dns_name                   = (known after apply)
      + enable_deletion_protection = true
      + enable_http2               = true
      + id                         = (known after apply)
      + idle_timeout               = 60
      + internal                   = false
      + ip_address_type            = (known after apply)
      + load_balancer_type         = "application"
      + name                       = "ALBTEST"
      + security_groups            = [
          + "sg-0c076144",
          + "sg-18e1fc63",
        ]
      + subnets                    = [
          + "subnet-71f20528",
          + "subnet-8f763183",
        ]
      + vpc_id                     = (known after apply)
      + zone_id                    = (known after apply)

      + access_logs {
          + bucket  = (known after apply)
          + enabled = true
          + prefix  = "true"
        }

      + subnet_mapping {
          + allocation_id = (known after apply)
          + subnet_id     = (known after apply)
        }
    }

  # module.stage.aws_lb_listener.http[0] will be created
  + resource "aws_lb_listener" "http" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 80
      + protocol          = "HTTP"
      + ssl_policy        = (known after apply)

      + default_action {
          + order = (known after apply)
          + type  = "fixed-response"

          + fixed_response {
              + content_type = "text/plain"
              + message_body = "200 OK"
              + status_code  = "200"
            }
        }
    }

  # module.stage.aws_lb_listener.https[0] will be created
  + resource "aws_lb_listener" "https" {
      + arn               = (known after apply)
      + certificate_arn   = "arn:aws:acm:us-east-1:157586424155:certificate/d6316a42-44f1-464a-9f49-f8f3a710f182"
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 443
      + protocol          = "HTTPS"
      + ssl_policy        = "ELBSecurityPolicy-2016-08"

      + default_action {
          + order = (known after apply)
          + type  = "fixed-response"

          + fixed_response {
              + content_type = "text/plain"
              + message_body = "200 OK"
              + status_code  = "200"
            }
        }
    }

  # module.stage.aws_lb_listener.redirect_http_to_https[0] will be created
  + resource "aws_lb_listener" "redirect_http_to_https" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 80
      + protocol          = "HTTP"
      + ssl_policy        = (known after apply)

      + default_action {
          + order = (known after apply)
          + type  = "redirect"

          + redirect {
              + host        = "#{host}"
              + path        = "/#{path}"
              + port        = "443"
              + protocol    = "HTTPS"
              + query       = "#{query}"
              + status_code = "HTTP_301"
            }
        }
    }

  # module.stage.aws_lb_listener_rule.http[0] will be created
  + resource "aws_lb_listener_rule" "http" {
      + arn          = (known after apply)
      + id           = (known after apply)
      + listener_arn = (known after apply)
      + priority     = 50000

      + action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }

      + condition {
          + field  = "path-pattern"
          + values = [
              + "/*",
            ]
        }
    }

  # module.stage.aws_lb_listener_rule.https[0] will be created
  + resource "aws_lb_listener_rule" "https" {
      + arn          = (known after apply)
      + id           = (known after apply)
      + listener_arn = (known after apply)
      + priority     = 50000

      + action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }

      + condition {
          + field  = "path-pattern"
          + values = [
              + "/*",
            ]
        }
    }

Plan: 7 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

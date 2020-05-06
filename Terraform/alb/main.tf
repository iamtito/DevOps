terraform {
  required_version = ">= 0.12"
}
module "s3log" {
  source       = "../s3"
  enable_alb   = var.enable_alb ? true : false
  alb_dns_name = var.alb_name
}

resource "aws_lb" "default" {
  count                      = var.enable_alb ? 1 : 0
  name                       = var.alb_name
  internal                   = var.alb_internal
  load_balancer_type         = "application"
  security_groups            = var.security_groups
  // subnets                    = var.subnets
  subnets                   = var.subnets == [""] ? tolist(var.subnets) : tolist(data.aws_subnet_ids.all.ids)
  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.enable_deletion_protection

  access_logs {
    bucket  = var.access_logs_enabled == true ? module.s3log.alb_bucket_id : var.access_logs_bucket
    prefix  = var.access_logs_prefix
    enabled = var.access_logs_enabled
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.alb_name
    },
  )
}


resource "aws_lb_listener" "default" {
  count = var.enable_https_listener ? length(var.alb_listeners) : 0
  // count             = var.enable_https_listener ? 1 : 0
  load_balancer_arn = aws_lb.default[0].arn
  port              = var.alb_listeners[count.index]["port"]
  protocol          = upper(var.alb_listeners[count.index]["protocol"]) //"HTTPS"
  certificate_arn   = lookup(var.alb_listeners[count.index], "certificate_arn", null, )
  ssl_policy        = lookup(var.alb_listeners[count.index], "ssl_policy", null, )

  default_action {
    target_group_arn = length(var.alb_listeners) > 1 ? (aws_lb_target_group.default[lookup(var.alb_listeners[count.index], "target_group_index", 0)].id) : (aws_lb_target_group.default[0].id)
    // target_group_arn = aws_lb_target_group.default[0].id
    // target_group_arn = aws_lb_target_group.default[lookup(var.alb_listeners[count.index], "target_group_index", 0)].id
    type             = "forward"
  }

  depends_on = [aws_lb_target_group.default]
}

resource "aws_lb_target_group" "default" {
  count = var.enable_target_group ? length(var.target_groups) : 0
  // count                = var.enable_target_group ? 1 : 0
  name                 = var.target_groups[count.index]["name"]
  vpc_id               = var.vpc_id == "" ? data.aws_vpc.prod.id : var.vpc_id
  port                 = var.target_groups[count.index]["backend_port"]
  protocol             = upper(var.target_groups[count.index]["backend_protocol"])
  deregistration_delay = lookup(var.target_groups[count.index], "deregistration_delay", var.target_groups_defaults["deregistration_delay"], )
  target_type          = lookup(var.target_groups[count.index], "target_type", var.target_groups_defaults["target_type"], )
  slow_start           = lookup(var.target_groups[count.index], "slow_start", var.target_groups_defaults["slow_start"], )

  health_check {
    interval            = lookup(var.target_groups[count.index], "health_check_interval", var.target_groups_defaults["health_check_interval"], )
    path                = lookup(var.target_groups[count.index], "health_check_path", var.target_groups_defaults["health_check_path"], )
    port                = lookup(var.target_groups[count.index], "health_check_port", var.target_groups_defaults["health_check_port"], )
    healthy_threshold   = lookup(var.target_groups[count.index], "health_check_healthy_threshold", var.target_groups_defaults["health_check_healthy_threshold"], )
    unhealthy_threshold = lookup(var.target_groups[count.index], "health_check_unhealthy_threshold", var.target_groups_defaults["health_check_unhealthy_threshold"], )
    timeout             = lookup(var.target_groups[count.index], "health_check_timeout", var.target_groups_defaults["health_check_timeout"], )
    protocol            = upper(lookup(var.target_groups[count.index], "healthcheck_protocol", var.target_groups[count.index]["backend_protocol"], ), )
    matcher             = lookup(var.target_groups[count.index], "health_check_matcher", var.target_groups_defaults["health_check_matcher"], )
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = lookup(var.target_groups[count.index], "cookie_duration", var.target_groups_defaults["cookie_duration"], )
    enabled         = lookup(var.target_groups[count.index], "stickiness_enabled", var.target_groups_defaults["stickiness_enabled"], )
  }

  tags = merge(
    var.tags,
    {
      "Name" = var.target_groups[count.index]["name"]
    },
  )
  
  depends_on = [aws_lb.default]

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  # setproduct works with sets and lists, but our variables are both maps
  # so we'll need to convert them first.
  target_group = [
    for key, target_group in aws_lb_target_group.default : {
      key          = key
      target_group = target_group.id
    }
  ]
  instances = [
    for key, instances in var.instances : {
      key    = key
      number = instances
    }
  ]
  tg_instances = [
    # in pair, element zero is a target_group and element one is a instance_id,
    # in all unique combinations.
    for pair in setproduct(local.target_group, var.instances) : {
      target_group      = pair[0].key
      instance_id       = pair[1]
      instance_i        = pair[1]
      target_group_id   = aws_lb_target_group.default[pair[0].key].id
      target_group_port = aws_lb_target_group.default[pair[0].key].port
    }
    // depends_on = [aws_lb_listener.default]
  ]
  depends_on = [aws_route53_record.lb_dns]
}
output "locals" {
  value = local.tg_instances
}
//// Terraform for_each is giving me headache, so punting auto registering of instances into alb for now
// resource "aws_lb_target_group_attachment" "default" {
//   for_each = {
//     for instances in local.tg_instances : "${instances.target_group}.${instances.instance_id}" => instances
//   }

//   target_group_arn = each.value.target_group_id //each.value.target_group.arn //
//   target_id        = each.value.instance_id
//   port             = each.value.target_group_port //each.value.target_group.port

//   depends_on = [local.tg_instances] //[aws_lb.default, aws_lb_listener.default, aws_lb_target_group.default, local.tg_instances]
// }

//// Another not tested attempt to enable auto registering to instance into the alb
// resource "aws_lb_target_group_attachment" "mysetup_grp1" {
//   count = "${aws_instance.mysetup_grp1.count}" 
//   target_group_arn = "${aws_lb_target_group.mysetup.arn}"
//   target_id        = "${element(aws_instance.mysetup_grp1.*.id, count.index)}"
//   port             = 3000

// }

resource "aws_route53_record" "lb_dns" {
  count   = var.enable_alb ? 1 : 0
  zone_id = var.zone_id == "" ? data.aws_route53_zone.route53-zone.id : var.zone_id
  name    = var.lb_dns_name
  type    = var.type
  alias {
    name                   = aws_lb.default[0].dns_name
    zone_id                = aws_lb.default[0].zone_id // var.lb_alias_zone_id
    evaluate_target_health = false
  }
  depends_on = [aws_lb_listener.default] //[aws_lb.default]
}

resource "aws_cloudwatch_metric_alarm" "alb_http400" {
  count               = var.enable_alb_http400 == "yes" ? 1:0
  alarm_name          = "[AWS ALB - ${var.alb_name}] Backend HTTP Status 400s above threshold (${var.alb_http400_threshold})"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "HTTPCode_Backend_4XX"
  namespace           = "AWS/ApplicationELB" 
  period              = "60"
  statistic           = "Sum"
  threshold           = var.alb_http400_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "This metric monitors the ${var.alb_name} ALB - HTTP 400s"
  alarm_actions       = [data.aws_sns_topic.sns_topic.arn]
  dimensions = {
    LoadBalancerName = aws_lb.default[0].arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_http400_target" {
  count               = var.enable_alb_http400_target == "yes" ? 1:0
  alarm_name          = "[AWS ALB - ${var.alb_name}] Backend Target HTTP Status 400s above threshold (${var.alb_http400_threshold})"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB" 
  period              = "60"
  statistic           = "Sum"
  threshold           = var.alb_http400_target_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "This metric monitors the ${var.alb_name} ALB - HTTP 400s"
  alarm_actions       = [data.aws_sns_topic.sns_topic.arn]
  dimensions = {
    LoadBalancerName = aws_lb.default[0].arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_http400count" {
  count               = var.enable_alb_http400count == "yes" ? 1:0
  alarm_name          = "[AWS ALB - ${var.alb_name}] HTTP Status 400s Count above threshold (${var.alb_http400_threshold})"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB" 
  period              = "60"
  statistic           = "Average"
  threshold           = var.alb_http400count_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "This metric monitors the ${var.alb_name} ALB - HTTP 400s"
  alarm_actions       = [data.aws_sns_topic.sns_topic.arn]
  dimensions = {
    LoadBalancerName = aws_lb.default[0].arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_http500" {
  count               = var.enable_alb_http500 == "yes" ? 1:0
  alarm_name          = "[AWS ALB - ${var.alb_name}] Backend HTTP Status 500s above threshold (${var.alb_http500_backend_threshold})"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "HTTPCode_Backend_5XX"
  namespace           = "AWS/ApplicationELB" 
  period              = "60"
  statistic           = "Sum"
  threshold           = var.alb_http500_backend_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "This metric monitors the ${var.alb_name} - HTTP 500s"
  alarm_actions       = [data.aws_sns_topic.sns_topic.arn]
  dimensions = {
    LoadBalancerName = aws_lb.default[0].arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb-surge" {
  count               = var.enable_alb_surge == "yes" ? 1:0
  alarm_name          = "[AWS ALB - ${var.alb_name}] Surge Queue Length Above Threshold (${var.alb_surge_threshold})"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "SurgeQueueLength"
  namespace           = "AWS/ApplicationELB" 
  period              = "60"
  statistic           = "Sum"
  threshold           = var.alb_surge_threshold
  treat_missing_data  = "notBreaching"
  alarm_description   = "This metric monitors the ${var.alb_name} ALB - Surge Queue Length"
  alarm_actions       = [data.aws_sns_topic.sns_topic.arn]
  dimensions = {
    LoadBalancerName = aws_lb.default[0].arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_target1" {
  count               = var.enable_alb_unhealthy_target1 == "yes" ? 1:0
  alarm_name          = "[AWS ALB - ${var.alb_name}] Unhealthy Hosts Exist on ${aws_lb_target_group.default[0].name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB" 
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "This metric monitors the ${var.alb_name} ALB - Unhealthy Hosts on ${aws_lb_target_group.default[0].name}"
  alarm_actions       = [data.aws_sns_topic.sns_topic.arn]
  ok_actions          = [data.aws_sns_topic.sns_topic.arn]
  dimensions = {
    TargetGroup  = aws_lb_target_group.default[0].arn_suffix
    LoadBalancer = aws_lb.default[0].arn_suffix
  }
}
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_target2" {
  count               = var.enable_alb_unhealthy_target2 == "yes" ? 1:0
  alarm_name          = "[AWS ALB - ${var.alb_name}] Unhealthy Hosts Exist on ${aws_lb_target_group.default[1].name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB" 
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "This metric monitors the ${var.alb_name} ALB - Unhealthy Hosts on ${aws_lb_target_group.default[1].name}"
  alarm_actions       = [data.aws_sns_topic.sns_topic.arn]
  ok_actions          = [data.aws_sns_topic.sns_topic.arn]
  dimensions = {
    TargetGroup  = aws_lb_target_group.default[1].arn_suffix
    LoadBalancer = aws_lb.default[0].arn_suffix
  }
}

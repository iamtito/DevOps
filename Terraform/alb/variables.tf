variable "enable_alb" {
  default     = true
  type        = bool
  description = "Set to false to prevent the module from creating anything. (Default: true)"
}

variable "alb_name" {
  default     = ""
  type        = string
  description = "(Required) The unique name of the LB."
}

variable "alb_internal" {
  default     = false
  type        = bool
  description = "If true, the LB will be internal."
}
variable "internal" {
  default     = false
  type        = bool
  description = "If true, the LB will be internal."
}

# A list of security group IDs to assign to the ALB.
variable "security_groups" {
  default     = [""]
  type        = list(string)
  description = "(Required) A list of security group IDs to attach to the ALB."
}

# A list of subnet IDs to attach to the ALB.
variable "subnets" {
  default     = [""]
  type        = list(string)
  description = "(Required) A list of subnet IDs to attach to the ALB."
}
variable "subnet_tag"{
  default = "prod"
}

variable "idle_timeout" {
  default     = 60
  type        = string
  description = "The time in seconds that the connection is allowed to be idle. (Default: 60)"
}

variable "enable_deletion_protection" {
  default     = false
  type        = bool
  description = "To prevent your load balancer from being deleted accidentally. If true, deletion of the load balancer will not be possible via the AWS API. (Default: false)"
}

//  Even if access_logs_enabled set false, you need to specify the valid bucket to access_logs_bucket."
variable "access_logs_bucket" {
  default     = ""
  type        = string
  description = "The S3 bucket name to store the logs in."
}

variable "access_logs_prefix" {
  default     = true
  type        = bool
  description = "The S3 bucket prefix. Logs are stored in the root if not configured."
}

variable "access_logs_enabled" {
  default     = true
  type        = bool
  description = "Boolean to enable/disable access_logs. (Default: true)"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of tags to assign to all resources."
}

//////// LISTENSER
variable "alb_listeners" {
  description = "A list of maps describing the HTTPS listeners for this ALB. Required key/values: port, certificate_arn. Optional key/values: ssl_policy (defaults to ELBSecurityPolicy-2016-08), target_group_index (defaults to 0)"
  type        = list(map(string))
  default     = []
}

variable "enable_https_listener" {
  default     = true
  type        = bool
  description = "If true, the HTTPS listener will be created."
}

variable "ssl_policy_default" {
  default     = "ELBSecurityPolicy-TLS-1-1-2017-01"
  type        = string
  description = "The name of the SSL Policy for the listener. Required if protocol is HTTPS."
}

variable "enable_target_group" {
  default     = true
  type        = bool
  description = "If true, the target group will be created."
}

variable "vpc_id" {
  default     = ""
  type        = string
  description = "The VPC to create the target group"
}

// TARGET GROUP VARIABLE
variable "target_groups_defaults" {
  description = "Default values for target groups as defined by the list of maps."
  type = object(
    {
      // The time period, in seconds, during which requests from a client should be routed to the same target. (Default: 86400 i.e 1day)
      cookie_duration = string,
      // The amount time for the load balancer to wait before changing the state of a deregistering target from draining to unused. (Default: 300)
      deregistration_delay = string,
      // The approximate amount of time, in seconds, between health checks of an individual target. (Default: 30)
      health_check_interval = string,
      // The number of consecutive health checks successes required before considering an unhealthy target healthy. (Default: 5)
      health_check_healthy_threshold = string,
      // The destination for the health check request. (Default: "/"")
      health_check_path = string,
      // The port to use to connect with the target. (Default: "traffic-port")
      health_check_port = string,
      // The amount of time, in seconds, during which no response means a failed health check. (Default: 5)
      health_check_timeout = string,
      // The number of consecutive health check failures required before considering the target unhealthy. (Default: 2)
      health_check_unhealthy_threshold = string,
      // The HTTP codes to use when checking for a successful response from a target.(Default: 200)
      health_check_matcher = string,
      // A Stickiness block. Stickiness blocks are documented below.(Default: true)
      stickiness_enabled = string,
      // The type of target that you must specify when registering targets with this target group. The possible values are instance or ip. (Default: false)
      target_type = string,
      // The amount time for targets to warm up before the load balancer sends them a full share of requests.
      slow_start = string,
    }
  )
  default = {
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
  }
}

variable "target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Required key/values: name, backend_protocol, backend_port. Optional key/values are in the target_groups_defaults variable."
  type        = list(map(string))
  default     = []
}

variable "aws_vpc" {
  default     = "Production"
  description = "Used by datasource for pulling vpc id allowing access to VPC endpoints. (Default: Production)"
}
variable "instances" {
  // default = ["i-ed74a93b","i-118766b3"]//"i-ed74a93b"
  default = [""]
}

variable "lb_dns_name" {
  default = ""
  description = "The route53 dns name for the load balancer"
}
variable "route_53_zone" {
  default = ""
  description = "The root domain name"
}

variable "type" {
  default     = "A"
  description = "Default(A Record). The record type. Valid values are A, AAAA, CAA, CNAME, MX, NAPTR, NS, PTR, SOA, SPF, SRV and TXT."
}
variable "zone_id" {
  default = ""
}

variable "sns_topic" {
  default ="ExternalCriticalAlerts"
}

variable "alb_surge_threshold" {
  default = "10"
}

variable "alb_alb500_threshold" {
  default = "5"
}

variable "alb_http500_backend_threshold" {
  default = "5"
}
variable "alb_http400_threshold" {
  default = "10"
}
variable "alb_http400count_threshold" {
  default = "10"
}
variable "alb_http400_target_threshold" {
  default = "10"
}
variable "enable_alb_http400" {
  default = "yes"
}
variable "enable_alb_http400_target" {
  default = "yes"
}
variable "enable_alb_http400count" {
  default = "yes"
}
variable "enable_alb_http500" {
  default = "yes"
}
variable "enable_alb_alb500" {
  default = "yes"
}
variable "enable_alb_surge" {
  default = "yes"
}
variable "enable_alb_unhealthy_target1" {
  default = "yes"
}
variable "enable_alb_unhealthy_target2" {
  default = "yes"
}

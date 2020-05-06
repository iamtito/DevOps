output "alb_id" {
  value       = join("", aws_lb.default.*.id)
  description = "The ARN of the load balancer (matches arn)."
}

output "alb_arn" {
  value       = join("", aws_lb.default.*.arn)
  description = "The ARN of the load balancer (matches id)."
}

output "alb_dns_name" {
  value       = join("", aws_lb.default.*.dns_name)
  description = "The DNS name of the load balancer."
}

output "alb_zone_id" {
  value       = join("", aws_lb.default.*.zone_id)
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
}

output "alb_target_group_id" {
  value       = join("", aws_lb_target_group.default.*.id)
  description = "The ARN of the Target Group (matches arn)"
}

output "alb_target_group_arn" {
  value       = join("", aws_lb_target_group.default.*.arn)
  description = "The ARN of the Target Group (matches id)"
}

output "alb_target_group_name" {
  value       = join("", aws_lb_target_group.default.*.name)
  description = "The name of the Target Group."
}

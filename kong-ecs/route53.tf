resource "aws_route53_record" "this" {
  zone_id = local.r53_zone_id
  name    = local.name
  type    = "A"

  alias {
    name                   = local.lb_dns
    zone_id                = local.lb_zone_id
    evaluate_target_health = true
  }
}

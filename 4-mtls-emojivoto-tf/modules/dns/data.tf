data "aws_route53_zone" "playground_hostedzone" {
  name         = var.domain_name
  private_zone = false
}
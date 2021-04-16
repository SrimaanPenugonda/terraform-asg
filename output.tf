output "sample" {
  value = "Hello World New Plugin"
}

output "TG_ARN" {
  value = aws_lb_target_group.tg.arn
}
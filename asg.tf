resource "aws_launch_template" "asg" {
  name            = "${var.COMPONENT}"-"${var.ENV}"
  image_id        = data.aws_ami.ami.id
  instance_type   = var.INSTANCE_TYPE
}
//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "asg" {
  name                      = "${var.COMPONENT}-${var.ENV}-asg"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  force_delete              = true
  launch_template {           //https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group#launch_template
    id                      = aws_launch_template.asg.id
    version                 = "$Latest"
}
  vpc_zone_identifier       = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS


  tag {
    key                 = "foo"
    value               = "bar"
    propagate_at_launch = true
  }

}

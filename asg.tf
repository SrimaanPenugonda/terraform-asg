resource "aws_launch_template" "asg" {
  name            = "${var.COMPONENT}-${var.ENV}-template"
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
  target_group_arns         = [aws_lb_target_group.tg.arn]
}

//creating target group
resource "aws_lb_target_group" "tg" {
  name                      = "${var.COMPONENT}-${var.ENV}-tg"
  port                      = var.PORT
  protocol                  = "HTTP"
  vpc_id                    = data.terraform_remote_state.vpc.outputs.VPC_ID
  health_check {
    path                    = var.HEALTH
  }
}

resource "aws_security_group" "allow_component" {
  name        = "allow-${var.COMPONENT}-${var.ENV}-sg"
  description = "Allow components to AMI"
  vpc_id      = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // allow only VPC and workstation - give VPC Cidr block
    //and workstation cidr block

  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // allow internet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-${var.COMPONENT}-ami-sg"
  }
}
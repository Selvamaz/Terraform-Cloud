
# Load Balancer for public subnet machines
resource "aws_lb" "dev-load-balancer" {
  name               = "dev-app-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dev-public-sg.id]

  subnet_mapping {
    subnet_id     = aws_subnet.dev-public-sub-01.id
  }

  subnet_mapping {
    subnet_id     = aws_subnet.dev-public-sub-02.id
  }

  tags = {
    Environment = "Dev-Application-LB"
  }
}

# Create a Target Group for all public subnets
resource "aws_lb_target_group" "alb-tg" {
  name        = "alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dev-vpc-tf-cloud.id
  depends_on = [aws_vpc.dev-vpc-tf-cloud]
}

# Create a listener for the target and aattach to ALB
resource "aws_lb_listener" "dev-instance" {
  load_balancer_arn = aws_lb.dev-load-balancer.arn
  port              =  80
  protocol          = "HTTP"
  depends_on = [ aws_lb.dev-load-balancer ]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

# Attach Subnet 01 Instances to Target Group
resource "aws_lb_target_group_attachment" "dev-instance-01-attach" {
  count            = length(aws_instance.dev-public-server-subnet-01)
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id        = element(aws_instance.dev-public-server-subnet-01.*.id, count.index)
  port             = 80
  depends_on = [ aws_lb_target_group.alb-tg ]
}

# Attach Subnet 02 Instances to Target Group
resource "aws_lb_target_group_attachment" "dev-instance-02-attach" {
  count            = length(aws_instance.dev-public-server-subnet-02)
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id        = element(aws_instance.dev-public-server-subnet-02.*.id, count.index)
  port             = 80
  depends_on = [ aws_lb_target_group.alb-tg ]
}
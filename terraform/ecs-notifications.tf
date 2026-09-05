# Optional notifications worker runtime on ECS Fargate.
# The main topology deploys every service to EKS; this resource supports the
# alternative SQS worker runtime when needed.

resource "aws_cloudwatch_log_group" "notifications" {
  name              = "/ecs/${local.name_prefix}-${var.notifications_service_name}"
  retention_in_days = var.notifications_log_retention_days
  tags              = local.common_tags
}

resource "aws_security_group" "notifications_ecs" {
  name        = "${local.name_prefix}-${var.notifications_service_name}-ecs-sg"
  description = "Security group for optional notifications ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_ecs_cluster" "main" {
  name = "${local.name_prefix}-ecs"
  tags = local.common_tags
}

resource "aws_ecs_task_definition" "notifications" {
  family                   = "${local.name_prefix}-${var.notifications_service_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.notifications_task_cpu)
  memory                   = tostring(var.notifications_task_memory)
  execution_role_arn       = var.ecs_lab_role_arn != "" ? var.ecs_lab_role_arn : null
  task_role_arn            = var.ecs_lab_role_arn != "" ? var.ecs_lab_role_arn : null

  container_definitions = jsonencode([
    {
      name      = var.notifications_service_name
      image     = var.notifications_image_uri != "" ? var.notifications_image_uri : "${aws_ecr_repository.this["notifications"].repository_url}:latest"
      essential = true
      environment = [
        { name = "MESSAGING_PROVIDER", value = "SQS" },
        { name = "MAIN_SQS_QUEUE_URL", value = aws_sqs_queue.payment_notification.url },
        { name = "AWS_REGION", value = var.aws_region }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.notifications.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = local.common_tags
}

resource "aws_ecs_service" "notifications" {
  name            = "${local.name_prefix}-${var.notifications_service_name}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.notifications.arn
  desired_count   = var.notifications_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.notifications_ecs.id]
    assign_public_ip = true
  }

  depends_on = [aws_cloudwatch_log_group.notifications]
  tags       = local.common_tags
}

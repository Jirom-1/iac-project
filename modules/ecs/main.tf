data "aws_iam_policy" "secret-manager-iam-policy" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

data "aws_iam_policy" "cloudwatch-iam-policy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name = "${var.project_name}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ecs-tasks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs-task-execution-secret-manager-policy-attachment" {
  name       = "${var.project_name}-ecs-task-execution-secret-manager-policy-attachment"
  roles      = [aws_iam_role.ecs-task-execution-role.name]
  policy_arn = data.aws_iam_policy.secret-manager-iam-policy.arn
}

resource "aws_iam_policy_attachment" "ecs-task-execution-cloudwatch-policy-attachment" {
  name       = "${var.project_name}-ecs-task-execution-cloudwatch-policy-attachment"
  roles      = [aws_iam_role.ecs-task-execution-role.name]
  policy_arn = data.aws_iam_policy.cloudwatch-iam-policy.arn
}

resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.project_name}-ecs-cluster"
}

resource "aws_ecs_service" "ecs-service" {
  name            = "${var.project_name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = 1
  network_configuration {
    subnets =  var.subnets
    security_groups = [aws_security_group.ecs_security_group.id]
    assign_public_ip = true 
  }
  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name = var.container_name
    container_port = var.port
  }
  launch_type = "FARGATE"

}

resource "aws_security_group" "ecs_security_group" {
  name        = "ecs-allow_http"
  description = "Allow http inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ecs-http_rules" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_security_group.id
}

resource "aws_security_group_rule" "ecs-egress-rule" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_security_group.id
}


resource "aws_ecs_task_definition" "ecs-task-definition" {
  family = "${var.project_name}-task-definition"
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "256"
  memory = "512"
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     =  var.image_name
      repositoryCredentials = {
        credentialsParameter = var.private_registry_secret_arn
      }
      essential = true
      portMappings = [
        {
          containerPort =  var.port
          hostPort      =  var.port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" = "${var.project_name}-ecs-logs"
          "awslogs-region" = "ca-central-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs-log-group" {
  name = "${var.project_name}-ecs-logs"
}

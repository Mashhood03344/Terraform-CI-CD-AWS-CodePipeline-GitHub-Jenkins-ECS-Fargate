variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "github_repository_owner" {
  description = "GitHub repository owner (username)"
  type = string
  default = "your-repository-owner"
}

variable "github_repository" {
  description = "GitHub repository name (username/repo)"
  type        = string
  default     = "your-repository-name"
}

variable "github_oauth_token" {
  description = "GitHub OAuth token for accessing the repository"
  type        = string
  sensitive   = true
  default = "your-personal-access-token"
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
  default     = "simple-html-app"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "simple-html-cluster"
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "simple-html-service"
}

variable "ecs_task_definition_name" {
  description = "Name of the ECS task definition"
  type        = string
  default     = "simple-html-task"
}

variable "jenkins_server_url" {
  description = "Server Url of the Jenkins Server"
  type        = string
  default     = "http://ec2-3-85-36-185.compute-1.amazonaws.com:8080/" # your Jenkins Ec2 instance URL woulud be like this 
}


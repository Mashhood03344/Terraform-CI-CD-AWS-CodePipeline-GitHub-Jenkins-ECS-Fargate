resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "simple-html-app-pipeline-artifacts"
}

# CodePipeline IAM Role
resource "aws_iam_role" "codepipeline_role" {
  name               = "codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
}

data "aws_iam_policy_document" "codepipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
  role       = aws_iam_role.codepipeline_role.name
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.codepipeline_role.name
}

# ECS and ECR Access Policies for CodePipeline
resource "aws_iam_role_policy_attachment" "ecs_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  role       = aws_iam_role.codepipeline_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.codepipeline_role.name
}

resource "aws_iam_policy" "codepipeline_policy" {
  name        = "codepipeline-policy"
  description = "Permissions for CodePipeline to interact with ECS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:ListTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attachment" {
  policy_arn = aws_iam_policy.codepipeline_policy.arn
  role       = aws_iam_role.codepipeline_role.name
}

# Custom Action for Jenkins (No actual provider required)
 resource "aws_codepipeline_custom_action_type" "jenkins_custom_action" {
   category = "Build"
   provider_name = "Build_Jenkins_4"  # This is the custom action provider name, not a Terraform provider
   version  = "1"

   configuration_property {
     description = "The name of the build project must be provided when this action is added to the pipeline."
     key         = true
     name        = "ProjectName"
     required    = true
     secret      = false
     type        = "String"
   }

   input_artifact_details {
     maximum_count = 5
     minimum_count = 0
   }

   output_artifact_details {
     maximum_count = 5
     minimum_count = 0
   }

   settings {
     entity_url_template    = "${var.jenkins_server_url}/job/{Config:ProjectName}/"
     execution_url_template = "${var.jenkins_server_url}/job/{Config:ProjectName}/{ExternalExecutionId}/"
   }

   tags = {
     Name = "custom-jenkins-action-type"
   }
}


# CodePipeline Resource
resource "aws_codepipeline" "ci_cd_pipeline" {
  name     = "simple-html-app-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_repository_owner
        Repo       = var.github_repository
        Branch     = "main"
        OAuthToken = var.github_oauth_token
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "BuildJenkins"
      category         = "Build"
      owner            = "Custom"
      provider         = "Build_Jenkins_4"  # This should match the custom action provider name
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = "Jenkins-pipeline"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      version          = "1"
      input_artifacts  = ["build_output"]

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
      }
    }
  }
}

// command for the jenkins provider in the aws codepipeline build stage 

// aws codepipeline list-action-types --region us-east-1 --action-owner-filter Custom

// aws codepipeline list-custom-action-types

# Deploying an ECS Cluster and CodePipeline with Jenkins Integration

## Overview

This is a step by step guide to deploying an ECS Cluster and setting up a CI/CD pipeline using AWS CodePipeline integrated with Jenkins. The setup involves provisioning an EC2 instance, installing necessary tools like Java, Jenkins, and Docker, and creating an ECS cluster using Terraform. We will also configure a Jenkins job and build the pipeline that automates the deployment of a simple HTML app.

## Prerequisites

Before starting, ensure you have the following:

 - An AWS account with access to services such as IAM, ECS, CodePipeline, and EC2.
 - Terraform installed on your local machine.
 - GitHub account to host the source code of the HTML app.
 - Basic knowledge of Jenkins, AWS, and Terraform.
 - Required Tools on EC2 Instance:
	- Java
	- Jenkins
	- Docker
	
## Step-by-Step Deployment Process

### Step 1: Provision an EC2 Instance

Launch an EC2 instance in the AWS console with the following specifications:
 - Instance type: t2.micro (free tier eligible).
 - Operating System: Amazon Linux 2 or Ubuntu 20.04 LTS.

Once the instance is running, SSH into the instance and run the following commands to install Java, Jenkins, and Docker.

 - Install Java
 - Install Jenkins
 - Install Docker
 
## Step 2: Jenkins Configuration

 - Access Jenkins by visiting http://<EC2-instance-public-IP>:8080.
 - Log in using the initial admin password located at /var/lib/jenkins/secrets/initialAdminPassword.
 - Install the necessary plugins (GitHub Integration, Pipeline, AWS CodePipline).
 - Create a new Jenkins project:
	- Go to New Item.
	- Select Freestyle Project.
	- Name the project Jenkins-pipeline.

 - Use the Jenkins configuration screenshots (provided separately) to configure the project.
 
## Step 3: Deploy ECS Cluster with Terraform

 - Clone the repository that contains the ECS cluster deployment script.
 - Define the variables (explained in the Variables section below).
 - Run the following Terraform commands to provision the infrastructure.

	```bash
	terraform init
	terraform apply
	```
	
**This script will create:**

 - An ECS Cluster.
 - A task execution role with appropriate permissions.
 - Two public subnets in different availability zones.
 - Security groups for allowing HTTP traffic.
 - An ECR repository to store Docker images.

##Step 4: Create AWS CodePipeline with Jenkins Integration

After the ECS cluster is deployed, use the provided Terraform script to create the CI/CD pipeline:

 - Run the following commands to deploy the pipeline:

	```bash
	terraform init
	terraform apply
	```
	
This will:

 - Create an S3 bucket for pipeline artifacts.
 - Set up the IAM roles with appropriate policies for ECS, ECR, and CodePipeline.
 - Define a CodePipeline with stages for Source (GitHub), Build (Jenkins), and Deploy (ECS).
 
**Note:** If you want to use Jenkins as the build provider in CodePipeline, ensure that the Jenkins custom action is configured properly. The Terraform configuration for the custom action is already provided in the pipeline script.

 
## Variables

The deployment scripts contain multiple variables. Make sure to set these variables appropriately before running the Terraform commands.

**ECS Cluster Deployment Variables:**

 - vpc_cidr: CIDR block for the VPC (e.g., 10.0.0.0/16).
 - subnet_cidr1: CIDR block for the first subnet (e.g., 10.0.1.0/24).
 - subnet_cidr2: CIDR block for the second subnet (e.g., 10.0.2.0/24).
 - aws_region: AWS region where the resources will be deployed (e.g., us-east-1).
 - ecr_repo_name: Name of the ECR repository (e.g., html-app-repo).
 - ecs_cluster_name: Name of the ECS cluster (e.g., html-app-cluster).
 - ecs_task_definition_name: Name of the ECS task definition (e.g., html-app-task).
 - ecs_service_name: Name of the ECS service (e.g., html-app-service).

**CodePipeline Variables:**

 - github_repository_owner: Owner of the GitHub repository (e.g., your-github-username).
 - github_repository: Name of the GitHub repository (e.g., simple-html-app).
 - github_oauth_token: OAuth token for GitHub integration.
 - ecs_cluster_name: Name of the ECS cluster (same as above).
 - ecs_service_name: Name of the ECS service (same as above).
 - jenkins_server_url: URL of your Jenkins server (e.g., http://<ec2-ip>:8080).
 
## Useful Commands

 - View Custom Action Types in CodePipeline:

	```bash
	aws codepipeline list-action-types --region us-east-1 --action-owner-filter Custom
	```
	
 - List All Custom Action Types:

	```bash
	aws codepipeline list-custom-action-types
	```
	
##Troubleshooting

If you encounter issues:

 - Verify that Jenkins, Java, and Docker are properly installed on the EC2 instance.
 - Check the Terraform logs for any issues related to AWS resource creation.
 - Ensure that your GitHub OAuth token has the necessary permissions to access the repository.
 - If further assistance is needed, consult the AWS and Terraform documentation or reach out to the community forums.
 

## Step 5: Cleanup

To avoid incurring unnecessary costs, it is important to clean up all the AWS resources once you no longer need them. Run the following commands to destroy the infrastructure:

	```bash
	terraform destroy -auto-approve
	```
	
This will delete:

 - The ECS Cluster and all related resources (VPC, Subnets, etc.).
 - The S3 bucket used for pipeline artifacts.
 - The CodePipeline and associated IAM roles.
 - Additional Information
 - Jenkins Provider in CodePipeline

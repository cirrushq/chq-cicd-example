# chq-cicd-example
CI/CD Deployment Example

This example repository will take you through the steps required to set up a CI/CD pipeline on AWS, connecting a GitHub repository to CodePipeline and deploying a small hellow world Flask App onto an EC2 instance running via uwsgi and Nginx.

This repository is provided as-is with no assumption of support from CirrusHQ, though if possible we will answer questions raised as issues. Deploying these CloudFormation templates will result in resources being created in AWS, such as an EC2 instance (a t3.micro), a nat gateway, an s3 bucket and a few more entries. Costs should be low, but do keep an eye on them.

This repository is linked to a webinar, which can be watched here [CI/CD Pipeline Webinar](https://www.cirrushq.com/webinar-delivery-of-higher-quality-software-faster-with-a-step-by-step-guide-on-creating-a-ci-cd-pipeline/). Slides are also available on this page that cover creating a CI/CD pipeline and why you would want to.

This repository contains the following:

- CloudFormation Templates
  - ec2infra - The example CloudFormation for an EC2 instance we'll be deploying onto
    - master.yml - The main template, which pulls in the rest of the templates as sub stack
    - vpc.yml - creates a VPC for our instance to be deployed into. Also creates an Internet Gateway 
    - security-groups.yml - creates a security group with port 80 open for application access, and port 22 from your IP
    - subnets.yml - creates subnets for the application to be deployed into and routing. Also creates a NAT Gateway for private routing
    - ec2.yml - Creates the instance, and roles and profiles for the instance to access services
  - pipeline - This is the CloudFormation for the pipeline that will deploy the code
    - pipeline.yml - creates CodeBuild, CodeDeploy and CodePipeline
- Application and Pipeline Setup
- configs
  - helloworld.conf - the NGINX config
  - helloworld.ini - the wsgi config
  - helloworld.service - the service for running wsgi
- scripts - these scripts run at various stages of the deployment process with hooks (defined in appspec.yml)
  - install_dependencies.sh - installs pip for later installation of prerequisites
  - install_services.sh - installs the service and sets up the nginx hosting file. Installs requirements file
  - start_server.sh - makes sure the services and web server are running
  - stop_server.sh - stops services (used when installing another update)
- buildspec.yml - the build process file. In this case all it does is ensure the deployment package has the right files passed into it
- appspec.yml - the file that determines how to install the application. We run 4 scripts at different points based on hooks in the deployment process
- helloworld.py - the sample flask application. Has 2 routes, / and /hellodevops, which return html
- wsgi.py - the Web Server Gateway Interface start fil, loads the helloworld app and runs it
- requirements.txt - python modules required for flask and uwsgi installation

## Prerequisites

- An AWS Account
- An S3 Bucket in the same region you will be deploying the code into. This will be used to hold the CloudFormation Templates
- Your IP address for SSH Access
- An EC2 Keypair for SSH Access [EC2 Key Pair Instructions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)
- A GitHub Account with a clone of this repository
- A Code Deploy Service Role
  - This role should be created manually, and have the AWS Managed Policy AWSCodeDeployRole, with CodeDeploy as the trusted service [Service Role Instructions](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-service.html)
  - A Domain you can point at the ec2 instance

## Deploying

Steps to Deploy:
- in the configs/helloworld.conf file, add your domain name into the server_name parameter (where it currently has mydomain.name). Commit this change to your repo clone
- Upload the cloudformation yaml files in the cloudformation/ec2infra folder to your S3 Bucket, in a folder. (Simplest way is to upload the ec2infra folder)
- Copy the link to the master.yml template (Under Object URL when you click on the file)
- Create a new Cloudformation Stack (with new resources), and use the Amazon S3 URL option, with the link you copied. The name of the stack should be unique from the pipeline stack below, I'd suggest using something-infra and something-pipeline to keep them separate
- Enter required parameters
  - CIDRBase - the cidr range to use, defaults to 10.88.0.0/16
  - BucketName - the name of your bucket, on it's own
  - BucketRegion - the region your bucket was created in
  - BucketFolder - the folder you uploaded the CloudFormation files in (ec2infra if following the example)
  - ApplicationName - a name to use for this application
  - Environment - usually dev, stage, uat or prod. 
  - SSHAccessIP - your IP address
  - KeyPairName - the name of the key pair you created earlier (don't add the .pem here)

Once deployed, you should have an EC2 instance up and running. 
- Add an A Record to your domain to point it at the IP address of the newly created instance.

At this point the site should return a html page with Hello World if you go to the root of the domain you set up.

## Pipeline Deployment
- Create a CodeStar connection to GitHub using the Application (This is NOT in the CodeStar section of the console, search for CodeBuild, then it's under the Settings section on the left) [GitHub Connection Setup](https://docs.aws.amazon.com/codepipeline/latest/userguide/connections-github.html)
- Copy the ARN for your new connection
- Create a new CloudFormation Stack using the file in pipeline/pipeline.yml (This can be uploaded rather than the S3 method as it's only 1 file). The name of the stack should be different from the infrastructure stack.
- Enter required parameters
  - GitHubConnectionARN - the ARN copied from above
  - GitHubRepo - your repository name. This should include your organisation name (This repo example would be cirrushq/chq-cicd-example)
  - GitHubBranch - the branch to deploy, in this case we are just using main
  - PipelineName - a name for your Code Pipeline
  - CodeDeployServiceRole - the ARN for the service role created above
  - EC2InstanceTagKey - which tags to target for deployment. You can use 'ApplicationName' to use the tag from the infra stack
  - EC2InstanceTagValue - the value in the tag being targetted. If using the tag ApplicationName, then use the same value you entered in the infra stack

Once this pipeline deploys it will automatically pull the current code and deploy it into the EC2 instance. You can see the progress and any errors in the CodePipeline console


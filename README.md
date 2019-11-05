# Codepipeline Workshop

This project contains source code and supporting files to do a workshop on Codepipeline.
The application uses several AWS resources, including Lambda functions and an API Gateway API. These resources are defined in the `template.yml` file in this project. You can update the template to add AWS resources through the same deployment process that updates your application code.


## Prerequisites

* Make sure your git credentials for codecommit (on your Isengard) are set (HTTPS/SSH) and ready to go
* AWS CLI (with default profile has Admin access to the AWS account)
* IDE (Like Pycharm, VS Code)

## Setup CodeCommit with sample code

* Create a <REPO-NAME> in your CodeCommit console and note down the <CodeCommit Git Clone URL>
* In the current project remove the .git directory (as it points to code.amazon.com repo)

```bash
$ rm -rf .git/
```
* Initialize the repo with git and push it to your CodeCommit <REPO-NAME>

```bash
$ git init
$ git remote add origin <CodeCommit Git Clone URL>
$ git add .
$ git commit -a -m "initial commit"
$ git push origin master
```
## Run the required setup stack

The setup stack creates necessary IAM roles used by Cloudformation, CodeBuild Project and roles, S3 buckets used by Codepipeline during pipeline transitions

Run the below command to create a setup stack at the project root level
```bash
$ aws cloudformation create-stack --stack-name workshop-setup --template-body file://setup/setup.yaml --capabilities CAPABILITY_IAM
```

### Below resources are created
| Logical ID's        | Resource Type           |
| ------------- |:-------------:|
| ArtifactBucket      | AWS::S3::Bucket | 
| SourceBucket      | AWS::S3::Bucket | 
| CloudformationLambdaTrustRole      | AWS::IAM::Role      |
| CodeBuild | AWS::CodeBuild::Project      |
| CodeBuildRole | AWS::IAM::Role      |


From your cloudformation console, look at the outputs section of workshop-setup and note down the 
**ArtifactBucket**

## Start the Codepipeline setup in the AWS console

Now that all the resources are in place (created by the setup stack), lets use them to create a Codepipeline in the console that will deploy an API Gateway which is backed by a lambda function 


### Configure the pipeline settings and choose Next.

* Pipeline name – workshop-pipeline
* Service role – New service role
* Artifact store – Custom location and fill in the 'Bucket' field with **ArtifactBucket** (created in setup stack)

### Source provider – S3
```
Bucket  – SourceBucket
S3 object key – app.zip
Change detection options – Amazon CloudWatch Events
```

### Configure build project settings and choose Continue to CodePipeline
```
Project Name - workshop-build (created as part of the stack)
```
### Configure deploy stage settings and choose Next
```
Deploy Provider - AWS Cloudformation
Action mode - Create or update a stack
Stack name - app-stack
Template section 
    - Artifact Name - BuildArtifact
    - File name - package.yml
Role name - <workshop-setup-CloudformationLambdaTrustRole-XXXXXXXXX
Capabilities – CAPABILITY_IAM , CAPABILITY_AUTO_EXPAND
```
### Create Pipeline
```
Review all the changes and click "Create Pipeline"
```



## Upload code to the SourceBucket (copied from setup stack output)

Now that the pipeline is ready to be used we will upload our SAM template to the SourceBucket
```bash
sh upload-code-to-s3.sh <SourceBucket>
```

Once the object (app.zip) is uploaded, go the Codepipeline console and follow the 
progress. The last stage is the deploy stage where the cloudformation stack is created/updated.


Now Go to CloudFormation console to look at the stack creation process. As the stack creation is complete
click on the Outputs section and retrieve the URL of the deployed application.

Make some changes to your code in app/index.js file and re-run the below command and and follow the progress in codepipeline 
```bash
sh upload-code-to-s3.sh <SourceBucket>
```


## Challenges

* Add an approval action in the deploy stage and change the 'runorder' (think [cli](https://docs.aws.amazon.com/cli/latest/reference/codepipeline/update-pipeline.html))

## Cleanup

To delete the sample application and the bucket that you created, use the AWS CLI.

* Delete the **"workshop-stack"** first 
* Empty the **SourceBucket** and **ArtifactBucket** manually

* Then run the below
```bash
sh delete-setup.sh
```

* Delete the pipeline from the Codepipeline console

## Resources

[AWS CodePipeline CLI](https://docs.aws.amazon.com/cli/latest/reference/codepipeline/index.html)
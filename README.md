# Codepipeline Workshop

This project contains source code and supporting files to do a workshop on Codepipeline.
The application uses several AWS resources, including Lambda functions and an API Gateway API. These resources are defined in the `template.yml` file in this project. You can update the template to add AWS resources through the same deployment process that updates your application code.

## Step.1 CLONE THIS REPO <br />

## Step.2 Prerequisites <br />

* Make sure your git credentials for codecommit (on your Isengard) are set (HTTPS/SSH) and ready to go
* AWS CLI (with default profile has Admin access to the AWS account)
* IDE (Like Pycharm, VS Code)

## Step.3 Setup CodeCommit with sample code

* Create a `<REPO-NAME>` in your CodeCommit console and note down the <CodeCommit Git Clone URL>
* In the current project root add the <CodeCommit Git Clone URL> as one of the remote destinations (Run the below commands)

```bash
$ git remote add codecommit <CodeCommit Git Clone URL>
$ git add .
$ git commit -a -m "initial commit"
$ git checkout -b master
$ git push codecommit master
```
## Step.4 Run the required setup stack

The setup stack creates necessary IAM roles used by Cloudformation, CodeBuild Project and roles, S3 buckets used by Codepipeline during pipeline transitions

Run the below command to create a setup stack name `workshop-setup` at the project root level
```bash
$ aws cloudformation create-stack --stack-name workshop-setup --template-body file://setup/setup.yaml --capabilities CAPABILITY_IAM
```

### Below resources are created
| Logical ID's        | Resource Type           |
| ------------- |:-------------:|
| ArtifactBucket      | AWS::S3::Bucket | 
| CloudformationLambdaTrustRole      | AWS::IAM::Role      |
| CodeBuild | AWS::CodeBuild::Project      |
| CodeBuildRole | AWS::IAM::Role      |


From your cloudformation console, look at the outputs section of `workshop-setup` and note down the `ArtifactBucket` and `CodeBuildName`


## Step.5 Start the Codepipeline setup in the AWS console

Now that all the resources are in place (created by the setup stack), lets use them to create a Codepipeline in the console that will deploy an API Gateway which is backed by a lambda function 


### Configure the pipeline settings and choose Next.

* Pipeline name – workshop-pipeline
* Service role – New service 

### Source provider – AWS CodeCommit
```
Repository name  – <REPO-NAME>
Branch name – master
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
    - File name - app/package.yml
Role name - <workshop-setup-CloudformationLambdaTrustRole-XXXXXXXXX
Capabilities – CAPABILITY_IAM , CAPABILITY_AUTO_EXPAND
```
### Create Pipeline
```
Review all the changes and click "Create Pipeline"
```


## Step.6 Start pipeline

Now that the pipeline is ready and hooked up, it will start automatically and deploy. The final step of the pipeline is a cloudformation deploy.

* Open the cloudformation console and look at the outputs section of the `app-stack`. The URL points to the API Gateway endpoint which is implemented by a lambda

## Step.7 Challenges

* Add an approval action in the deploy stage and re-release the pipeline from the top (or commit new code in the app/directory)

* Change the 'runorder' of the approval stage and the deploy stage (think [cli](https://docs.aws.amazon.com/cli/latest/reference/codepipeline/update-pipeline.html))

## Step.8 CLEANUP ****** IMPORTANT ******


To delete the sample application and the bucket that you created, use the AWS CLI.

* Delete the `app-stack` first from the cloudformation console

* Empty the `ArtifactBucket` manually

* Then run the below to remove the setup stack
```bash
aws cloudformation delete-stack --stack-name workshop-setup 
```

* Delete the pipeline from the Codepipeline console

* Delete the CodeCommit repo
## Resources

[AWS CodePipeline CLI](https://docs.aws.amazon.com/cli/latest/reference/codepipeline/index.html)
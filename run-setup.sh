#!/usr/bin/env bash

aws cloudformation create-stack --stack-name workshop-setup --template-body file://setup/setup.yaml --capabilities CAPABILITY_IAM
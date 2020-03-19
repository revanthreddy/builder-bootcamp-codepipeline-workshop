#!/usr/bin/env bash

aws cloudformation delete-stack --stack-name workshop-setup --template-body file://setup/setup.yaml --capabilities CAPABILITY_IAM
#!/usr/bin/env bash

if [ $# -ne 1 ]
then
    echo 'upload_to_s3.sh  <SOURCE_ARTIFACT_BUCKET_NAME>'
    exit 1
fi

source_artifact_bucket_name=$1
zip_name=app.zip

cd app

zip -r $zip_name . -x *.git*
aws s3 cp $zip_name s3://$source_artifact_bucket_name
rm $zip_name


#!/bin/bash

set -euo pipefail

COMMAND=${1:-}
if [[ $COMMAND != "create-layer" ]] && [[ $COMMAND != "publish-layer" ]] && [[ $COMMAND != "deploy-stack" ]] && [[ $COMMAND != "update-lambda" ]]; then
  echo
  echo "COMMAND must be one of (create-layer, publish-layer, deploy-stack)!"
  echo "Exiting."
  exit 1
fi

# NAME=${2:-}
# if [[ -z "$NAME" ]]; then
#   echo
#   echo "NAME is empty!"
#   echo "Exiting."
#   exit 1
# fi

case $COMMAND in

  create-layer)

  echo
  cd layers/opencv-python37
  echo "Creating the contents of the opencv-python37 lambda layer."
  docker build --tag=lambda-layer-factory:latest .
  docker run --rm --interactive --tty --volume $(pwd):/data lambda-layer-factory cp /packages/opencv-python37.zip /data
  cd ../..
  ;;

  publish-layer)

  echo
  echo "Publishing opencv-python37 lambda layer."
  cd layers/opencv-python37
  aws lambda publish-layer-version --layer-name opencv-python37 \
      --description "OpenCV-Python 3.7 and its dependencies." \
      --zip-file fileb://opencv-python37.zip --compatible-runtimes "python3.7"
  rm opencv-python37.zip
  cd ../..
  ;;

  deploy-stack)
  echo

  LAMBDA_LAYER_ARN=arn:aws:lambda:$AWS_DEFAULT_REGION:$AWS_ACCOUNT_ID:layer:opencv-python37:4

  echo "Deploying the test-opencv-python37 CloudFormation Stack."
  aws cloudformation deploy --template-file cloudformation.yaml --stack-name test-opencv-python37 \
  --capabilities CAPABILITY_NAMED_IAM --region $AWS_DEFAULT_REGION --parameter-overrides LambdaLayerArn=$LAMBDA_LAYER_ARN
  ;;

  update-lambda)
  echo
  echo "Updating lambda function."
  cd lambda
  zip image_processing_lambda.zip image_processing_lambda.py
  aws lambda update-function-code --function-name test-opencv-python37-lambda-function --zip-file fileb://image_processing_lambda.zip
  rm image_processing_lambda.zip
  cd ..
  ;;

esac

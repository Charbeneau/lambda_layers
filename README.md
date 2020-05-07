# lambda_layers
Let's cram OpenCV into a lambda using layers!

## Background

[AWS Lambda functions](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html) are nifty.

A useful feature of theirs is the [layer](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html), which allows one to cram a bunch of stuff into them.

Here we use a layer to put [OpenCV](https://github.com/skvark/opencv-python) into a lambda and do serverless image processing.

The image processing done here is very simple:  converting from color to grayscale.  

Obviously, one could do more complicated things using this same framework.

Everything is done with [driver.sh](./driver.sh) and [cloudformation.yaml](./cloudformation.yaml), so take a look at them.

Note that all of the resources incorporate the name of the CloudFormation stack in them.  

See the uses of `${AWS::StackName}` throughout cloudformation.yaml.

## Requirements

- [Python](https://www.python.org/)
- Environment Variables
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
  - AWS_DEFAULT_REGION
  - AWS_ACCOUNT_ID

## Usage

0. Create a Python virtual environment, here called **deployment_env** and done with [virtualenvwrapper](https://virtualenvwrapper.readthedocs.io/en/latest/).
```
mkvirtualenv deployment_env --no-site-packages
workon deployment_env
pip install -r deployment_env_requirements.txt
```

1. Create the lambda layer.
```
bash driver.sh create-layer
```

You should see a Docker image being built.
```

Creating the contents of the opencv-python37 lambda layer.
Sending build context to Docker daemon   50.5MB
Step 1/12 : FROM amazonlinux
.
.
.
Successfully tagged lambda-layer-factory:latest
```

2. Publish the lambda layer.
```
bash driver.sh publish-layer
```

After publishing the layer, you should see something like this.

```
Publishing opencv-python37 lambda layer.
{
    "Content": {
.
.
.
    "CompatibleRuntimes": [
        "python3.7"
    ]
}
```

Take note of the lambda layer version number.

3. **Update LAMBDA_LAYER_ARN in driver.sh to have the layer version number matching the one you want to use.**

This should be parameterized in the future.

4. Deploy the CloudFormation stack.
```
bash driver.sh deploy-stack
```

You should see something like this.
```
Deploying the test-opencv-python37 CloudFormation Stack.

Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - test-opencv-python37
```

5. Update the lambda function.
```
bash driver.sh update-lambda
```

You should see something like this.
```
Updating lambda function.
  adding: image_processing_lambda.py (deflated 63%)
{
    "FunctionName": "test-opencv-python37-lambda-function",
.
.
.
    "State": "Active",
    "LastUpdateStatus": "Successful"
}
```

6. Find [images/input/my_image.jpg](images/input/my_image.jpg), and put it in the test-opencv-python37-input-image-bucket S3 bucket.

7. Go to the test-opencv-python37-output-image-bucket S3 bucket, and find a grayscale image that should look like [images/output/my_image_gray.jpg](images/output/my_image_gray.jpg).

## Next Steps

I'm going to make the driver.sh parameters named [like so](https://brianchildress.co/named-parameters-in-bash/).

## Miscellanea

To nuke all Docker images.  **Watch out!**
```
docker system prune --all --force --volumes
```

Delete layer versions.
```
aws lambda delete-layer-version --layer-name opencv-python37 --version-number 3
```

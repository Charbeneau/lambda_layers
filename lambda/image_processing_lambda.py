import logging
import os
import boto3
import cv2
import json

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)


INPUT_IMAGE_BUCKET = os.environ.get('INPUT_IMAGE_BUCKET', None)
OUTPUT_IMAGE_BUCKET = os.environ.get('OUTPUT_IMAGE_BUCKET', None)

s3 = boto3.client('s3')


def handler(event, context):

    logger.info('INPUT_IMAGE_BUCKET: {0}'.format(INPUT_IMAGE_BUCKET))
    logger.info('OUTPUT_IMAGE_BUCKET: {0}'.format(OUTPUT_IMAGE_BUCKET))

    for record in event['Records']:

        in_key = record['s3']['object']['key']
        out_key = in_key[:-4] + '_gray.jpg'
        in_tmp = '/tmp/' + in_key
        out_tmp = in_tmp[:-4] + '_gray.jpg'

        try:
            logger.info('Downloading s3://{0}/{1} to {2}.'.format(INPUT_IMAGE_BUCKET, in_key, in_tmp))  # noqa: E501
            with open(in_tmp, 'wb') as file:
                s3.download_fileobj(INPUT_IMAGE_BUCKET, in_key, file)

                logger.info('Reading in {0} as an image.'.format(in_tmp))
                image = cv2.imread(in_tmp)

            logger.info('Converting to grayscale.')
            image_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

            logger.info('Writing grayscale image to {0}.'.format(out_tmp))
            with open(out_tmp, 'wb') as file:
                cv2.imwrite(out_tmp, image_gray)
                logger.info('Uploading grayscale image to s3://{0}/{1}.'.format(OUTPUT_IMAGE_BUCKET, out_key))  # noqa: E501
                s3.upload_file(out_tmp, OUTPUT_IMAGE_BUCKET, out_key)

        except Exception as e:
            logger.info(e)
            raise e

    message = "Grayscale image uploaded to s3://{0}/{1}.".format(OUTPUT_IMAGE_BUCKET, out_key)
    response = {"status_code": 200, "body": json.dumps({"message": message})}

    logger.info('Here is the response returned.')
    logger.info(response)

    logger.info('Goodbye!')

    return response

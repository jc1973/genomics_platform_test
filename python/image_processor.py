import os
import json
import uuid
import boto3

from PIL import Image

dest_bucket = 'image-processor-processed'
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    print(event)

    # Create the directories
    try:
        os.makedirs('/tmp/source')
    except:
        pass

    try:
        os.makedirs('/tmp/processed')
    except:
        pass
    
    # getting bucket and object key from event object
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    
    # creating download path and downloading the img object from S3
    object_key = str(uuid.uuid4()) + '-' + key
    img_download_path = '/tmp/source/{}'.format(object_key)
    
    with open(img_download_path,'wb') as img_file:
        s3_client.download_fileobj(source_bucket, key, img_file)
    
    # processed img path
    img_processed_path = '/tmp/processed/{}'.format(object_key)

    # Creating and saving img thumbnail from downloaded img
    source_img = Image.open(img_download_path)
    source_img.thumbnail((img_width,img_height))
    source_img.save(img_thumbnail_path)
    
    # uploading img thumbnail to destination bucket
    upload_key = 'thumbnail-{}'.format(object_key)
    s3_client.upload_file(img_thumbnail_path, dest_bucket,upload_key)

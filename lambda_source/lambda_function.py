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
    print(source_bucket)
    print(key)

    # creating download path and downloading the img object from S3
    object_key = str(uuid.uuid4()) + '-' + key
    img_download_path = '/tmp/source/{}'.format(object_key)
    # print(object_key)
    
    with open(img_download_path,'wb') as img_file:
        s3_client.download_fileobj(source_bucket, key, img_file)
    
    # processed img path
    img_processed_path = '/tmp/processed/{}'.format(object_key)

    # Creating and saving img thumbnail from downloaded img
    source_img = Image.open(img_download_path)
    data = list(source_img.getdata())
    img_without_exif = Image.new(source_img.mode, source_img.size)
    img_without_exif.putdata(data)
    img_without_exif.save(img_processed_path)
    
    # uploading img withoux exif to destination bucket
    upload_key = '{}'.format(object_key)
    s3_client.upload_file(img_processed_path, dest_bucket,upload_key)

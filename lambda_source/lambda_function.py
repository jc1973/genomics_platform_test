import os
import json
import uuid
import boto3

import importlib
pil_spec = importlib.util.find_spec("PIL")
found = pil_spec is not None
print('Pillow found:' , found)

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

    print(os.listdir('/tmp'))
    
    # getting bucket and object key from event object
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    print(source_bucket)
    print(key)

    # creating download path and downloading the img object from S3
    # # object_key = str(uuid.uuid4()) + '-' + key
    # img_download_path = '/tmp/source/{}'.format(object_key)
    img_download_path = '/tmp/source/' + key
    # print(object_key)
    print('Download image path ' + img_download_path)
    
    with open(img_download_path,'wb') as img_file:
        s3_client.download_fileobj(source_bucket, key, img_file)
    print('Checking to see if imaga downloaded to /tmp/source ' , os.listdir('/tmp/source'))
    print('Checking size of file' , os.stat(img_download_path))
 
    # processed img path
    # img_processed_path = '/tmp/processed/{}'.format(object_key)
    img_processed_path = '/tmp/processed/' + key
    print('Procesed image location:' + img_processed_path)

    # Creating and saving img thumbnail from downloaded img
    try:
        source_img = Image.open(img_download_path)
        print('opened image')
    except:
        print('Cannot open image')

    print('trying to get data')
    try:
        data = list(source_img.getdata())
        print('Got Data')
    except:
        print ('Cannot exec: data = list(source_img.getdata())')

    img_without_exif = Image.new(source_img.mode, source_img.size)
    img_without_exif.putdata(data)
    img_without_exif.save(img_processed_path)
    print('saved image: ' , os.listdir('/tmp/processed'))
    
    # uploading img withoux exif to destination bucket
    # upload_key = '{}'.format(object_key)
    # s3_client.upload_file(img_processed_path, dest_bucket,upload_key)

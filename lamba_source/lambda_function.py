import os
import json
import uuid
import boto3
import imghdr

from urllib.parse import unquote_plus

import importlib
exif_spec = importlib.util.find_spec("exif")
found = exif_spec is not None
print('exif found:' , found)


from exif import Image

dest_bucket = 'image-processor-processed'
s3_client = boto3.client('s3')

def strip_exif_image(src_image, dst_image):
    print('opening image')
    with open(src_image, 'rb') as image:
        src_image = Image(image)
    print('deleting EXIF data')
    src_image.delete_all()
    print('Saving image')
    with open(dst_image, 'wb') as dst_file:
        dst_file.write(src_image.get_file())    
    print('EXIF data from image removed and saved')

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
    key = unquote_plus(event['Records'][0]['s3']['object']['key'])
    print(source_bucket)
    print(key)

    # creating download path and downloading the img object from S3
    img_download_path = '/tmp/source/' + key
    img_processed_path = '/tmp/processed/' + key
    s3_client.download_file(source_bucket, key, img_download_path)

    print('Checking to see if imaga downloaded to /tmp/source ' , os.listdir('/tmp/source'))
    print('Checking size of file' , os.stat(img_download_path))

    # Check to see if image is a jpeg (don't rely on extension)
    img_type = imghdr.what(img_download_path)
    if img_type != 'jpeg':
        print('Error: file ' + img_download_path + 'is not a jpeg')
        raise NameError('File is not a jpeg: ' + key)
    
    strip_exif_image(img_download_path, img_processed_path)
    
    print('saved image: ' , os.listdir('/tmp/processed'))
    print('Checking size of upload file' , os.stat(img_download_path))
    print('Checking size of processed file' , os.stat(img_processed_path))

    s3_client.upload_file(img_processed_path, dest_bucket, key)

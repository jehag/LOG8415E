import os
import requests
from flask import Flask

app = Flask(__name__)

instance_id = requests.get('http://169.254.169.254/latest/meta-data/instance-id').text
# region = requests.get("http://169.254.169.254/latest/dynamic/instance-identity/document").json()['region']
# name = os.popen('aws ec2 describe-tags --region {} --filters "Name=resource-id,Values={}" "Name=key,Values=Name" --output text | cut -f5'.format(region, instance_id)).read()[:-1]

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def hello(path = None):
    return instance_id + ' is responding now!'

if __name__ == '__main__':
      app.run()

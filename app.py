###
# flask application deployed on the instances
###
import send_requests
from flask import Flask

app = Flask(__name__)

# get the name of the ec2 instance
instance_id = send_requests.get('http://169.254.169.254/latest/meta-data/instance-id').text

# route every requests to hello(), regardless of the path (equivalent to a wildcard)
@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def hello(path = None):
    return instance_id + ' is responding now!'

if __name__ == '__main__':
      app.run()

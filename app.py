import send_requests
from flask import Flask

app = Flask(__name__)

instance_id = send_requests.get('http://169.254.169.254/latest/meta-data/instance-id').text

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def hello(path = None):
    return instance_id + ' is responding now!'

if __name__ == '__main__':
      app.run()

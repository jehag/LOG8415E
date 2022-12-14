#!/bin/bash

# install python and nginx
apt-get update -y
apt-get install python3-venv -y
apt-get install nginx -y

# pull flask app files from git
if cd /home/ubuntu/LOG8415E
then git pull
else cd /home/ubuntu && git clone https://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@github.com/jehag/LOG8415E.git
fi

# copy service file to systemd folder
cp /home/ubuntu/LOG8415E/flaskapp.service /etc/systemd/system

# setup python virtual environment
cd /home/ubuntu/LOG8415E

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# setup and start flaskapp service (gunicorn)
systemctl daemon-reload
systemctl start flaskapp
systemctl enable flaskapp

# setup and start nginx service
systemctl start nginx
systemctl enable nginx

cp /home/ubuntu/LOG8415E/default /etc/nginx/sites-available

# restart both service to express changes
systemctl restart flaskapp
systemctl restart nginx

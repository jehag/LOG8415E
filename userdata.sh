#!/bin/bash

apt-get update -y
apt-get install python3-venv -y
apt-get install nginx -y
apt-get install awscli -y

if cd /home/ubuntu/LOG8415E
then git pull
else cd /home/ubuntu && git clone https://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@github.com/jehag/LOG8415E.git
fi

mkdir /home/ubuntu/.aws

cp /home/ubuntu/LOG8415E/credentials /home/ubuntu/.aws
cp /home/ubuntu/LOG8415E/flaskapp.service /etc/systemd/system

cd /home/ubuntu/LOG8415E

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

systemctl daemon-reload
systemctl start flaskapp
systemctl enable flaskapp

systemctl start nginx
systemctl enable nginx

cp /home/ubuntu/LOG8415E/default /etc/nginx/sites-available

systemctl restart flaskapp
systemctl restart nginx

# script to run the project
# requires the ~/.aws/credentials file to contain valid credentials
# requires docker to be installed
# requires awscli to be installed

# pull docker image that contains all the files required for the project
docker pull bawsje/log8415e_1:latest

# run docker image with aws credentials passed as environment variables
docker run -e AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id) -e AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key) -e AWS_SESSION_TOKEN=$(aws configure get aws_session_token) bawsje/log8415e_1:latest
docker pull bawsje/log8415e_2:latest
DOCKER_ID=$(docker run -d -e aws_access_key_id=$(aws configure get aws_access_key_id) -e aws_secret_access_key=$(aws configure get aws_secret_access_key) -e aws_session_token=$(aws configure get aws_session_token) -v /var/run/docker.sock:/var/run/docker.sock bawsje/log8415e_2:latest)
docker logs -f $DOCKER_ID
$SHELL
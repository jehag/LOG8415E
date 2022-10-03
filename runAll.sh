docker pull bawsje/log8415e_2:latest
docker run -e aws_access_key_id=$(aws configure get aws_access_key_id) -e aws_secret_access_key=$(aws configure get aws_secret_access_key) -e aws_session_token=$(aws configure get aws_session_token) bawsje/log8415e_2:latest
$SHELL
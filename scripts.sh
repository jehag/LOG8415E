terraform init
terraform apply -auto-approve
docker pull bawsje/log8415e_1:latest
DOCKER_ID=$(docker run -d -e URL=$(terraform output --raw dns_address) bawsje/log8415e_1:latest)
docker logs -f $DOCKER_ID
$SHELL
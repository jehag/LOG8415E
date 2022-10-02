terraform init
terraform apply -auto-approve
docker pull bawsje/log8415e_1:latest
docker run -e URL=$(terraform output --raw dns_address) bawsje/log8415e_1:latest
$SHELL
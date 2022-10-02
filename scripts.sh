terraform init
terraform apply -auto-approve
docker build -t python_container .
docker run -e URL=$(terraform output dns_address) python_container
$SHELL
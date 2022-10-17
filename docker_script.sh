#!/bin/bash
######################################################################
# Step1: unzip terraform in usr/bin
cd /usr/bin
unzip terraform_1.3.1_linux_amd64.zip
rm terraform_1.3.1_linux_amd64.zip

cd /usr/app/src

######################################################################
# Step2: create the resources with terraform
echo # to get live logs in the terminal
terraform init
terraform apply -auto-approve

printf 'HTTP route initialization ...\n'
# delay to make sure HTTP route is accessible
sleep 20

######################################################################
# Step3: send the requests to each cluster
printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -
# save the requests start time for benchmarking purposes
export REQUESTS_START=$(date +%s) 
python3 send_requests.py $(terraform output --raw dns_address)

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -
printf 'Benchmarking ...\n'

# save the benchmark start time for benchmarking purposes
export BENCHMARK_START=$(date +%s) 

# delay to wait for the requests metrics to update
sleep 80

######################################################################
# Step4: get the metrics data between REQUESTS_START and the current time

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -

python3 benchmark.py 

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -

printf '60 seconds left before resources are destroyed ...\n'

sleep 60

######################################################################
# Step5: clean up the resources used
printf 'destroying resources ...\n'

terraform destroy -auto-approve > /dev/null

printf 'destroyed resources\n'

sleep 10
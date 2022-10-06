#!/bin/bash

# unzip terraform in usr/bin
cd /usr/bin
unzip /usr/bin/terraform_1.3.1_linux_amd64.zip \
  && rm /usr/bin/terraform_1.3.1_linux_amd64.zip

cd /usr/app/src

echo
terraform init
terraform apply -auto-approve

printf 'HTTP route initialization ...\n'
# delay to make sure HTTP route is accessible
sleep 20

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -

# save the requests start time for benchmarking purposes
export REQUESTS_START=$(date +%s) 

# send the requests to each cluster
python3 send_requests.py $(terraform output --raw dns_address)

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -

printf 'Benchmarking ...\n'

# save the benchmark start time for benchmarking purposes
export BENCHMARK_START=$(date +%s) 

# delay to wait for the requests metrics to update
sleep 80

# get the metrics data between REQUESTS_START and the current time
python3 benchmark.py 

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -

printf '60 seconds left before resources are destroyed ...\n'

sleep 60

printf 'destroying resources ...\n'

terraform destroy -auto-approve > /dev/null

printf 'destroyed resources\n'

sleep 10
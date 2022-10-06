#!/bin/bash
echo
terraform init
terraform apply -auto-approve

printf 'HTTP route initialization ...\n'
# delay to make sure HTTP route is accessible
sleep 10

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -

# save the requests start time for benchmarking purposes
export REQUESTS_START=$(date +%s) 

# send the requests to each cluster
python send_requests.py $(terraform output --raw dns_address)

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -

printf 'Benchmarking ...\n'

# save the benchmark start time for benchmarking purposes
export BENCHMARK_START=$(date +%s) 

# delay to wait for the requests metrics to update
sleep 60

# get the metrics data between REQUESTS_START and the current time
python benchmark.py 

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -

printf '60 seconds before destroying resources ...\n'

sleep 60

printf 'destroying resources ...\n'

terraform destroy -auto-approve > /dev/null

printf 'destroyed resources\n'

sleep 10
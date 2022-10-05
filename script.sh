#!/bin/bash
echo
terraform init
terraform apply -auto-approve

printf 'HTTP route initialization ...\n'
# delay to make sure HTTP route is accessible
sleep 10

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -

export BENCHMARK_START=$(date +%s) 

python3 send_requests.py $(terraform output --raw dns_address)


printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -

printf 'Benchmarking ...\n'
# delay to wait for last requests metrics to update

python3 benchmark.py

printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' -

terraform destroy -auto-approve > /dev/null
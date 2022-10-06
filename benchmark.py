import boto3
import os
import sys
from datetime import timedelta, datetime
from tabulate import tabulate

cloudwatch_client = boto3.client('cloudwatch', 'us-east-1')

def handler(metricname, targetgrouparn, lbarn):
    result = access_last_data_metric(metricname, targetgrouparn, lbarn)
    return result

def access_last_data_metric(metricname, targetGroup, loadBalancer):
    start = datetime.utcnow() - timedelta(minutes = 15)
    end = datetime.utcnow()
    if 'REQUESTS_START' in os.environ:
        start = datetime.utcfromtimestamp(int(os.environ['REQUESTS_START']))

    dimension = [ { 'Name': 'LoadBalancer', 'Value': loadBalancer } ]
    if targetGroup != None: dimension.append({ 'Name': 'TargetGroup', 'Value': targetGroup })
    
    response = cloudwatch_client.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'myrequest',
                'MetricStat': {
                    'Metric': {
                        'Namespace': 'AWS/ApplicationELB',
                        'MetricName': metricname,
                        'Dimensions': dimension
                    },
                    'Period': 60,
                    'Stat': 'Average' if metricname == 'TargetResponseTime' else 'Sum',
                    'Unit': 'Seconds' if metricname == 'TargetResponseTime' else 'Count'
                }
            },
        ],
        StartTime=start,
        EndTime=end
    )
    return sum(response['MetricDataResults'][0]['Values'])

if __name__ == "__main__":

    lb = os.popen('terraform output --raw lb_arn_suffix').read()
    cluster1 = os.popen('terraform output --raw cluster1_arn_suffix').read()
    cluster2 = os.popen('terraform output --raw cluster2_arn_suffix').read()

    metric_names = ['RequestCount', 'TargetResponseTime', 'HTTPCode_Target_2XX_Count', 'HTTPCode_Target_4XX_Count']
    headers = ['Target', 'Request count', 'Average response time (s)', 'Status 2XX', 'Status 4XX']
    cluster1_data = ['Cluster1']
    cluster2_data = ['Cluster2']
    total_data = ['Total']

    #clusters metrics
    for metric in metric_names:
        cluster1_data.append(handler(metric, cluster1, lb))
        cluster2_data.append(handler(metric, cluster2, lb))

    benchmark = tabulate([cluster1_data, cluster2_data], headers=headers)
    print(benchmark)

    print() # newline for prettier formatting

    # load balancer metrics
    lb_metric_names = ['RequestCount', 'TargetResponseTime', 'HTTPCode_ELB_2XX_Count', 'HTTPCode_ELB_4XX_Count', 'HTTPCode_ELB_5XX_Count']
    lb_headers = ['Request count', 'Average response time (s)', 'Status 2XX', 'Status 4XX', 'Status 5XX']
    lb_data = ['Load balancer']

    for metric in lb_metric_names:
        lb_data.append(handler(metric, None, lb))

    lb_benchmark = tabulate([lb_data], headers=headers)
    print(lb_benchmark)


    if 'BENCHMARK_START' in os.environ:
        print('total time since requests sent (s): ' + str((datetime.utcnow() - datetime.utcfromtimestamp(int(os.environ['REQUESTS_START']))).total_seconds()))

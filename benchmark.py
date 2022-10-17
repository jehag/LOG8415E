import boto3
import os
from datetime import timedelta, datetime
from tabulate import tabulate

cloudwatch_client = boto3.client('cloudwatch', 'us-east-1')

def access_last_data_metric(metricName, targetGroup, loadBalancer):
    """
    access_last_data_metric fetches the sum of all data points of the targeted 
    metric on cloudwatch from the start of the http calls to the current time.

    :param metricname: the name of the metric to fetch
    :param targetGroup
    """
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
                        'MetricName': metricName,
                        'Dimensions': dimension
                    },
                    'Period': 60,
                    'Stat': 'Average' if metricName == 'TargetResponseTime' else 'Sum',
                    'Unit': 'Seconds' if metricName == 'TargetResponseTime' else 'Count'
                }
            },
        ],
        StartTime=start,
        EndTime=end
    )
    return sum(response['MetricDataResults'][0]['Values'])

if __name__ == "__main__":

    # get arn_suffixes from terraform outputs
    lb = os.popen('terraform output --raw lb_arn_suffix').read()
    cluster1 = os.popen('terraform output --raw cluster1_arn_suffix').read()
    cluster2 = os.popen('terraform output --raw cluster2_arn_suffix').read()

    #clusters metrics
    metric_names = ['RequestCount', 'TargetResponseTime', 'HTTPCode_Target_2XX_Count', 'HTTPCode_Target_4XX_Count']
    headers = ['Target', 'Request count', 'Average response time (s)', 'Status 2XX', 'Status 4XX']
    cluster1_data = ['Cluster1']
    cluster2_data = ['Cluster2']
    total_data = ['Total']

    for metric in metric_names:
        cluster1_data.append(access_last_data_metric(metric, cluster1, lb))
        cluster2_data.append(access_last_data_metric(metric, cluster2, lb))

    benchmark = tabulate([cluster1_data, cluster2_data], headers=headers)
    print(benchmark)

    print() # newline for prettier formatting

    # load balancer metrics
    lb_metric_names = ['RequestCount', 'TargetResponseTime', 'HTTPCode_ELB_2XX_Count', 'HTTPCode_ELB_4XX_Count', 'HTTPCode_ELB_5XX_Count']
    lb_headers = ['Request count', 'Average response time (s)', 'Status 2XX', 'Status 4XX', 'Status 5XX']
    lb_data = ['Load balancer']

    for metric in lb_metric_names:
        lb_data.append(access_last_data_metric(metric, None, lb))

    lb_benchmark = tabulate([lb_data], headers=lb_headers)
    print(lb_benchmark)

    # time elapsed since the requests (http calls from send_requests) were sent
    if 'BENCHMARK_START' in os.environ:
        print('total time since requests sent (s): ' + str((datetime.utcnow() - datetime.utcfromtimestamp(int(os.environ['REQUESTS_START']))).total_seconds()))

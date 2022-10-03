resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "my-dashboard"

  dashboard_body = jsonencode(
{
    "widgets": [
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_alb.alb.arn_suffix ]
                ],
                "period": var.cloudwatch_period,
                "region": "us-east-1",
                "stacked": false,
                "stat": "Sum",
                "title": "Total request count",
                "view": "timeSeries",
                "yAxis": {
                    "left": {
                        "label": "Count",
                        "showUnits": false
                    }
                }
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 6,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_alb.alb.arn_suffix ]
                ],
                "period": var.cloudwatch_period,
                "region": "us-east-1",
                "stacked": false,
                "stat": "Average",
                "title": "Average request response time",
                "view": "timeSeries",
                "yAxis": {
                    "left": {
                        "label": "Time",
                        "showUnits": true
                    }
                }
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count", "LoadBalancer", aws_alb.alb.arn_suffix ],
                    [ ".", "HTTPCode_ELB_5XX_Count", ".", "." ]
                ],
                "period": var.cloudwatch_period,
                "region": "us-east-1",
                "stacked": false,
                "stat": "Sum",
                "title": "Load Balancer request failures",
                "view": "timeSeries",
                "yAxis": {
                    "left": {
                        "label": "Count",
                        "showUnits": false
                    }
                }
            }
        },
    ]
}
  )
}
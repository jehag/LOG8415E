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
    ]
}
  )
}
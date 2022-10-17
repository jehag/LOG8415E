/*
 * Cloudwatch dashboard initialisation. 
 * Contains metrics data from the load balancer and the target groups
 */
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
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 18,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "NewConnectionCount", "LoadBalancer", aws_alb.alb.arn_suffix ],
                    [ ".", "ActiveConnectionCount", ".", "." ]
                ],
                "period": var.cloudwatch_period,
                "region": "us-east-1",
                "stacked": false,
                "stat": "Sum",
                "title": "Connections",
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
            "y": 6,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCount", "TargetGroup", aws_alb_target_group.cluster1.arn_suffix, "LoadBalancer", aws_alb.alb.arn_suffix ],
                    [ "...", aws_alb_target_group.cluster2.arn_suffix, ".", "." ]
                ],
                "period": var.cloudwatch_period,
                "region": "us-east-1",
                "stacked": false,
                "stat": "Sum",
                "title": "Request count per target group",
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
            "y": 6,
            "x": 6,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", aws_alb_target_group.cluster1.arn_suffix, "LoadBalancer", aws_alb.alb.arn_suffix ],
                    [ "...", aws_alb_target_group.cluster2.arn_suffix, ".", "." ]
                ],
                "period": var.cloudwatch_period,
                "region": "us-east-1",
                "stacked": false,
                "stat": "Average",
                "title": "Average request response time per target group",
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
            "y": 6,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "TargetGroup", aws_alb_target_group.cluster1.arn_suffix, "LoadBalancer", aws_alb.alb.arn_suffix ],
                    [ ".", ".", ".", aws_alb_target_group.cluster2.arn_suffix, ".", "." ]
                ],
                "period": var.cloudwatch_period,
                "region": "us-east-1",
                "stacked": false,
                "stat": "Sum",
                "title": "Request 4XX failures per target group",
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
            "y": 6,
            "x": 18,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "RequestCountPerTarget", "TargetGroup", aws_alb_target_group.cluster1.arn_suffix, "LoadBalancer", aws_alb.alb.arn_suffix ],
                    [ "...", aws_alb_target_group.cluster2.arn_suffix, ".", "." ]
                ],
                "period": var.cloudwatch_period,
                "region": "us-east-1",
                "stacked": false,
                "stat": "Sum",
                "title": "Average request count per instance",
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
            "y": 12,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", aws_alb_target_group.cluster1.arn_suffix, "LoadBalancer", aws_alb.alb.arn_suffix ],
                    [ ".", "UnHealthyHostCount", ".", ".", ".", "." ]
                ],
                "period": var.cloudwatch_period,
                "region": "us-east-1",
                "stacked": false,
                "stat": "Average",
                "title": "Cluster 1 host status",
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
            "y": 12,
            "x": 6,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", aws_alb_target_group.cluster2.arn_suffix, "LoadBalancer", aws_alb.alb.arn_suffix ],
                    [ ".", "UnHealthyHostCount", ".", ".", ".", "." ]
                ],
                "period": var.cloudwatch_period,
                "region": "us-east-1",
                "stacked": false,
                "stat": "Average",
                "title": "Cluster 2 host status",
                "view": "timeSeries",
                "yAxis": {
                    "left": {
                        "label": "Count",
                        "showUnits": false
                    }
                }
            }
        }
    ]
}
  )
}
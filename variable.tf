/*
 * instance counts for clusters
 * instance_count[0] is the number of instance in cluster 1
 * instance_count[1] is the number of instance in cluster 2
 */
variable "instance_count" {
  type = list(string)
  default = [
    4,
    5
    ]
}

/*
 * instance type for clusters
 * instance_type[0] is the type of instance in cluster 1
 * instance_type[1] is the type of instance in cluster 2
 */
variable "instance_type" {
  type = list(string)
  default = [
    "m4.large",
    "t2.large"
    ]
}

/*
 * availability zones for clusters
 * each cluster will contain instances from both availability zones
 */
variable "availability_zone" {
    type = list(string)
    default = [
        "us-east-1c",
        "us-east-1d"
    ]
}

variable "cloudwatch_period" {
  default = 60
}
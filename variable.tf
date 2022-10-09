variable "instance_count" {
  type = list(string)
  default = [
    4,
    5
    ]
}

variable "instance_type" {
  type = list(string)
  default = [
    "m4.large",
    "t2.large"
    ]
}

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
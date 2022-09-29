variable "instance_count" {
  default = "3"
}

variable "instance_type" {
  type = list(string)
  default = [
    "t2.micro",
    "t1.micro"
    ]
}

variable "availability_zone" {
    type = list(string)
    default = [
        "us-east-1c",
        "us-east-1d"
    ]
}
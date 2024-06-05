variable "ami-id"{
    description="ami instance id"
    type=string
    default="ami-05e00961530ae1b55"
}
variable "aws-region"{
    description="Instance Creation Zone"
    type=string
    default="ap-south-1"
}
variable "public-instance-count"{
    description="No of public instance needed"
    type=string
    default=3
}
variable "private-instance-count"{
    description="No of private instance needed"
    type=string
    default=2
}
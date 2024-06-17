variable "ami-id"{
    description="ami instance id"
    type=string
    default="ami-05e00961530ae1b55"
}
variable "instance-type"{
    description="Instance Type"
    type=string
    default="t2.micro"
}
variable "instance_key"{
    description="Instance Key"
    type=string
    default="Selva_Linux_April_2024"
}
variable "aws-region"{
    description="Instance Creation Region"
    type=string
    default="ap-south-1"
}
variable "region-zone1"{
    description="Region Zone 1"
    type=string
    default="ap-south-1a"
}
variable "region-zone2"{
    description="Region Zone 2"
    type=string
    default="ap-south-1b"
}
variable "region-zone3"{
    description="Region Zone 3"
    type=string
    default="ap-south-1c"
}
variable "public-sub-01-cidr" {
    description="Public Subnet 1 CIDR Value"
    type=string
    default="10.0.1.0/24"
}
variable "public-sub-02-cidr" {
    description="Public Subnet 2 CIDR Value"
    type=string
    default="10.0.2.0/24"
}
variable "private-sub-01-cidr" {
    description="Private Subnet 1 CIDR Value"
    type=string
    default="10.0.3.0/24"
}
variable "private-sub-02-cidr" {
    description="Private Subnet 2 CIDR Value"
    type=string
    default="10.0.4.0/24"
}
variable "public-instance-count"{
    description="No of public instance needed"
    type=string
    default=3
}

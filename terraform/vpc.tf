provider "aws" {
    region = var.region
}

variable region {}
variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}

data "aws_availability_zones" "azs" {}  # set AZ's dynamically depending on the region


  # --------------------------------------------------------------------------- Module: VPC
  # for EKS we need special VPC similar to VPC that AWS-CloudFormation creates in the process of creating EKS through UI 
module "myapp-vpc" { # this module will be automaticcaly downloaded after $ terraform init
    source = "terraform-aws-modules/vpc/aws"
    version = "3.2.0"

    name = "myapp-vpc"
    cidr = var.vpc_cidr_block
    private_subnets = var.private_subnet_cidr_blocks  # private subnet for each available-zone
    public_subnets = var.public_subnet_cidr_blocks    # public subnet for each available-zone
    azs = data.aws_availability_zones.azs.names  # to get name: google:aws_availability_zones    
    
    enable_nat_gateway = true  # default: one NAT gateway per subnet
    single_nat_gateway = true  # all private subnets will route their internet traffic through this single NAT gateway. worker-nodes and master are in different VPCs of master-nodes and they need to talk to each other
    enable_dns_hostnames = true  # assign public and private dns
       
    tags = {  # REQUIRED TAG # for human consumption
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"                # cluster name. helps cloud-control-manager identify which vpc and cluster should connect to
    }

    public_subnet_tags = {  # REQUIRED TAG # consumed by Elastic Load Balancer
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"                # cluster name. helps cloud-control-manager identify which vpc and cluster should connect to
        "kubernetes.io/role/elb" = 1                                        # to connect to ELB
    }

    private_subnet_tags = {  # REQUIRED TAG # consumed by loadbalance service
        "kubernetes.io/cluster/myapp-eks-cluster" = "shared"                 # cluster name. helps cloud-control-manager identify which vpc and cluster should connect to
        "kubernetes.io/role/internal-elb" = 1                                # to connect to k8s-load-blancer
    }

}

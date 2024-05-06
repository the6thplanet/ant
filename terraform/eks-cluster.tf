provider "kubernetes" { # query following from AWS in order to login to K8s
    load_config_file = "false" # we dont want k8s to load deafult config file in .kube/config. we are creating new one
    host = data.aws_eks_cluster.myapp-cluster.endpoint  # endpoint of cluster (API server) # to get endpoint attribute: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster
    token = data.aws_eks_cluster_auth.myapp-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
}

data "aws_eks_cluster" "myapp-cluster" { 
    name = module.eks.cluster_id # to get cluster_id attribute: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest?tab=outputs
}

data "aws_eks_cluster_auth" "myapp-cluster" { 
    name = module.eks.cluster_id
}


  # ------------------------------------------------------------------------------- Module: EKS
module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "17.1.0"
    
    cluster_name = "myapp-eks-cluster"   
    cluster_version = "1.28"   # K8s version

    subnets = module.myapp-vpc.private_subnets   
    vpc_id = module.myapp-vpc.vpc_id  # VPC of the subnet  

    tags = {
        environment = "development" 
        application = "Ant International Group"  
    }
    
    worker_groups = [  
        {
            instance_type = "t2.micro"  
            name = "worker-group-1"     
            asg_desired_capacity = 2 
        },
        {
            instance_type = "t2.micro"
            name = "worker-group-2"
            asg_desired_capacity = 1
        }
    ]
}
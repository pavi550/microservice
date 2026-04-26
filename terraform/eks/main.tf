locals {
  project_name            = "my-microservice-project"
  ami_type                = "AL2_x86_64"
  azs                     = slice(data.aws_availability_zones.available.names, 0, 2)
  capacity_type           = "SPOT"
  cluster_name            = "my-eks-cluster-v2"
  cluster_version         = "1.31"
  disk_size               = 20
  enable_cluster_creation = true
  enable_nat_gateway      = false
  enable_public_access    = true
  instance_type           = "t3.micro"
  node_desired_capacity   = 1
  node_max_capacity       = 2
  node_min_capacity       = 1
  private_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet_cidrs     = ["10.0.3.0/24", "10.0.4.0/24"]
  single_nat_gateway      = false
  vpc_cidr_block          = "10.0.0.0/16"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.project_name}-vpc"
  cidr = local.vpc_cidr_block
  azs  = local.azs

  private_subnets = local.private_subnet_cidrs
  public_subnets  = local.public_subnet_cidrs

  enable_nat_gateway      = local.enable_nat_gateway
  single_nat_gateway      = local.single_nat_gateway
  map_public_ip_on_launch = true

  enable_dns_hostnames = true

  enable_flow_log = false
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.18.0"

  create                                   = local.enable_cluster_creation
  name                                     = local.cluster_name
  kubernetes_version                       = local.cluster_version
  endpoint_public_access                   = local.enable_public_access
  enable_cluster_creator_admin_permissions = true
  create_cloudwatch_log_group              = false

  encryption_config = null
  create_kms_key    = false

  addons = {
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  eks_managed_node_groups = {
    my_node_group = {
      desired_size       = local.node_desired_capacity
      max_size           = local.node_max_capacity
      min_size           = local.node_min_capacity
      instance_types     = [local.instance_type]
      capacity_type      = local.capacity_type
      disk_size          = local.disk_size
      ami_type           = local.ami_type
      kubernetes_version = local.cluster_version
    }
  }
}

local {
  project_name = "my-microservice-project"
  ami_type = "al2_x86_64"
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  capacity_type = "SPOT"
  cluster_name = "my-eks-cluster"
  cluster_version = "1.27"
  disk_size = 20
  enable_cluster_creation = true
  enable_nat_gateway = true
  enable_public_access = true
  instance_type = "t2.micro"  disk_type = "gp2"
  node_desired_capacity = 3
  node_max_capacity = 5
  node_min_capacity = 1
  infra_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  public_subnet_cidrs = ["10.0.5.0/24", "10.0.6.0/24"]
  single_nat_gateway = true
  vpc_cidr_block = "10.0.0.0/16"

}
data "aws_availability_zones" "available" {
  state = "available"
}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"
  name = "${local.project_name}-vpc" #my-eks-cluster-vpc
  cidr_block = local.vpc_cidr_block
  enable_nat_gateway = local.enable_nat_gateway
  enable_public_access = local.enable_public_access
  azs = local.azs
  infra_subnet_cidrs = local.infra_subnet_cidrs
  app_subnet_cidrs = local.private_subnet_cidrs
  public_subnet_cidrs = local.public_subnet_cidrs
}
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "3.14.0"
    cluster_name = local.cluster_name   
  region = "us-east-1"
  azs = local.azs
  cidr_block = local.vpc_cidr_block
  infra_subnet_cidrs = local.infra_subnet_cidrs
  app_subnet_cidrs = local.private_subnet_cidrs
  public_subnet_cidrs = local.public_subnet_cidrs
  single_nat_gateway = local.single_nat_gateway

eks_managed_node_groups = {
    my_node_group = {
      desired_capacity = local.node_desired_capacity
      max_capacity     = local.node_max_capacity
      min_capacity     = local.node_min_capacity
      instance_types   = [local.instance_type]
      disk_size       = local.disk_size
      disk_type       = local.disk_type
      capacity_type    = local.capacity_type
    }
  } 
  launch_template = {
    name_prefix   = "${local.project_name}-node"
    image_id      = data.aws_ami.eks_worker_ami.id
    instance_type  = local.instance_type
    disk_size      = local.disk_size
    disk_type      = local.disk_type
  }
  max_size = local.node_max_capacity
  min_size = local.node_min_capacity
  version = local.cluster_version
  create_cluster = local.enable_cluster_creation
}

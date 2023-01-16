
locals {
  subnet_ids = <<subnet_ids>>
  create_service_accounts = <<enable_aws_secret_manager>>
}

################################################################################
# EC2 Key Pair Module
################################################################################


resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "../../terraform_modules/key-pair"

  key_name   = "<<key_name>>"
  public_key = tls_private_key.this.public_key_openssh
}

output "private_key" {
  value     = tls_private_key.this.private_key_pem
  sensitive = true
}

################################################################################
# S3 Buket Module
################################################################################
resource "aws_s3_bucket" "bucket" {
  bucket = "<<cinchy_s3_bucket>>"
  
  tags = {
    Environment = "<<cinchy_s3_environment_tag>>"
    terraformed = true
  }
}

################################################################################
# EKS Module
################################################################################
module "eks" {
  source = "../../terraform_modules/eks"

  cluster_name                    = "<<cluster_name>>"
  cluster_version                 = "<<cluster_version>>"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = "<<vpc_id>>"
  subnet_ids = local.subnet_ids

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    },
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    },
    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = <<disk_size>>
    instance_types         = <<instance_types>>
  }

  eks_managed_node_groups = {
    cinchy-nodes-az-1 = {
      min_size     = <<min_size>>
      max_size     = <<max_size>>
      desired_size = <<desired_size>>
      key_name = module.key_pair.key_pair_key_name
      subnet_ids = [local.subnet_ids[0]]
    }
    cinchy-nodes-az-2 = {
      min_size     = <<min_size>>
      max_size     = <<max_size>>
      desired_size = <<desired_size>>
      key_name = module.key_pair.key_pair_key_name
      subnet_ids = [local.subnet_ids[1]]
    }
    cinchy-nodes-az-3 = {
      min_size     = <<min_size>>
      max_size     = <<max_size>>
      desired_size = <<desired_size>>
      key_name = module.key_pair.key_pair_key_name
      subnet_ids = [local.subnet_ids[2]]
    }
  }
}


# ################################################################################
# # RDS Aurora Module
# ################################################################################

module "aurora" {
  source  = "../../terraform_modules/aurora"

  name           = "<<database_instance_name>>"
  database_name  = "<<database_name>>"
  engine         = "aurora-postgresql"
  engine_version = "<<engine_version>>"
  instance_class = "<<instance_class>>"
  port           = 5432
  instances = {
    instance-1 = {}
    # instance-2 = {} # Multi-AZ RDS when you add more than one instances.
  }

  vpc_id  = "<<vpc_id>>"
  subnets = local.subnet_ids
  
  allowed_security_groups = ["${module.eks.cluster_security_group_id}"]
  allowed_cidr_blocks     = <<allowed_cidr_blocks>>
  publicly_accessible     = <<publicly_accessible>>

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  db_parameter_group_name         = "default.aurora-postgresql14"
  db_cluster_parameter_group_name = "default.aurora-postgresql14"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Environment = "<<aurora_environment_tag>>"
    terraformed = true
  }
}

output "aurora_rds_password" {
  value     = module.aurora.cluster_master_password
  sensitive = true
}
output "aurora_cluster_endpoint" {
  value     = module.aurora.cluster_endpoint
}


#--------------------------------------------
# Deploy Kubernetes Add-ons with sub module
#--------------------------------------------
module "eks-kubernetes-addons" {
    source = "../../terraform_modules/kubernetes-addons"

    eks_cluster_id                               = module.eks.cluster_id
    #K8s Add-ons
    enable_metrics_server                        = true
    enable_cluster_autoscaler                    = true
    enable_secrets_store_csi_driver_provider_aws = <<enable_aws_secret_manager>>
    enable_secrets_store_csi_driver              = <<enable_aws_secret_manager>>
    depends_on                                   = [module.eks.managed_node_groups]
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "aws" {
  region = data.aws_region.current.id
  alias  = "default"
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

#-----------------------------------------------------------------
# Secret and stores in AWS Secret Manager
#-----------------------------------------------------------------

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "eks_cluster" {
  name = module.eks.cluster_id
}

#------------------------------------------------------------------------------------
# This creates a IAM Policy content limiting access to the secret in Secrets Manager
#------------------------------------------------------------------------------------

data "aws_iam_policy_document" "<<instance_name>>_secrets_management_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    resources = <<aws_secrets_manager_arn_list>>
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
  }
}

#---------------------------------------------------------------
# Creating IAM Policy to be attached to the IRSA Role
#---------------------------------------------------------------

resource "aws_iam_policy" "<<instance_name>>_aws_iam_policy" {
  description = "AWS Secret Manager IAM Policy for IRSA"
  name        = "${module.eks.cluster_id}-irsa-<<instance_name>>"
  policy      = data.aws_iam_policy_document.<<instance_name>>_secrets_management_policy.json
}

# Create a Namespace
resource kubernetes_namespace <<instance_name>> {
  count = local.create_service_accounts == true ? 1 : 0
  metadata {
    name = "<<instance_name>>"
    labels = {
      "env"                        = "<<cinchy_instance_name>>"
      "istio-injection"            = "enabled"
    }
  }
}

#---------------------------------------------------------------
# Creating IAM Role for Service Account
#---------------------------------------------------------------
module "<<instance_name>>-iam-role-connections-serviceaccount" {
  source                     = "../../terraform_modules/irsa"
  create_kubernetes_namespace = false
  count = local.create_service_accounts == true ? 1 : 0
  eks_cluster_id             = module.eks.cluster_id
  eks_oidc_provider_arn      = module.eks.oidc_provider_arn
  kubernetes_namespace       = "<<instance_name>>"
  kubernetes_service_account = "connections-serviceaccount"
  irsa_iam_policies          = [aws_iam_policy.<<instance_name>>_aws_iam_policy.arn]

  depends_on = [
    module.eks,
    kubernetes_namespace.<<instance_name>>
  ]
}

module "<<instance_name>>-iam-role-event-listener-serviceaccount" {
  source                     = "../../terraform_modules/irsa"
  create_kubernetes_namespace = false
  count = local.create_service_accounts == true ? 1 : 0
  eks_cluster_id             = module.eks.cluster_id
  eks_oidc_provider_arn      = module.eks.oidc_provider_arn
  kubernetes_namespace       = "<<instance_name>>"
  kubernetes_service_account = "event-listener-serviceaccount"
  irsa_iam_policies          = [aws_iam_policy.<<instance_name>>_aws_iam_policy.arn]

  depends_on = [
    module.eks,
    kubernetes_namespace.<<instance_name>>
  ]
}

module "<<instance_name>>-iam-role-forms-serviceaccount" {
  source                     = "../../terraform_modules/irsa"
  create_kubernetes_namespace = false
  count = local.create_service_accounts == true ? 1 : 0
  eks_cluster_id             = module.eks.cluster_id
  eks_oidc_provider_arn      = module.eks.oidc_provider_arn
  kubernetes_namespace       = "<<instance_name>>"
  kubernetes_service_account = "forms-serviceaccount"
  irsa_iam_policies          = [aws_iam_policy.<<instance_name>>_aws_iam_policy.arn]

  depends_on = [
    module.eks,
    kubernetes_namespace.<<instance_name>>
  ]
}

module "<<instance_name>>-iam-role-idp-serviceaccount" {
  source                     = "../../terraform_modules/irsa"
  create_kubernetes_namespace = false
  count = local.create_service_accounts == true ? 1 : 0
  eks_cluster_id             = module.eks.cluster_id
  eks_oidc_provider_arn      = module.eks.oidc_provider_arn
  kubernetes_namespace       = "<<instance_name>>"
  kubernetes_service_account = "idp-serviceaccount"
  irsa_iam_policies          = [aws_iam_policy.<<instance_name>>_aws_iam_policy.arn]

  depends_on = [
    module.eks,
    kubernetes_namespace.<<instance_name>>
  ]
}

module "<<instance_name>>-iam-role-maintenance-cli-serviceaccount" {
  source                     = "../../terraform_modules/irsa"
  create_kubernetes_namespace = false
  count = local.create_service_accounts == true ? 1 : 0
  eks_cluster_id             = module.eks.cluster_id
  eks_oidc_provider_arn      = module.eks.oidc_provider_arn
  kubernetes_namespace       = "<<instance_name>>"
  kubernetes_service_account = "maintenance-cli-serviceaccount"
  irsa_iam_policies          = [aws_iam_policy.<<instance_name>>_aws_iam_policy.arn]

  depends_on = [
    module.eks,
    kubernetes_namespace.<<instance_name>>
  ]
}

module "<<instance_name>>-iam-role-web-serviceaccount" {
  source                     = "../../terraform_modules/irsa"
  create_kubernetes_namespace = false
  count = local.create_service_accounts == true ? 1 : 0
  eks_cluster_id             = module.eks.cluster_id
  eks_oidc_provider_arn      = module.eks.oidc_provider_arn
  kubernetes_namespace       = "<<instance_name>>"
  kubernetes_service_account = "web-serviceaccount"
  irsa_iam_policies          = [aws_iam_policy.<<instance_name>>_aws_iam_policy.arn]

  depends_on = [
    module.eks,
    kubernetes_namespace.<<instance_name>>
  ]
}

module "<<instance_name>>-iam-role-worker-serviceaccount" {
  source                     = "../../terraform_modules/irsa"
  create_kubernetes_namespace = false
  count = local.create_service_accounts == true ? 1 : 0
  eks_cluster_id             = module.eks.cluster_id
  eks_oidc_provider_arn      = module.eks.oidc_provider_arn
  kubernetes_namespace       = "<<instance_name>>"
  kubernetes_service_account = "worker-serviceaccount"
  irsa_iam_policies          = [aws_iam_policy.<<instance_name>>_aws_iam_policy.arn]

  depends_on = [
    module.eks,
    kubernetes_namespace.<<instance_name>>
  ]
}
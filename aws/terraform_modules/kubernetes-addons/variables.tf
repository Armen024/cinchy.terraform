variable "eks_cluster_id" {
  description = "EKS Cluster Id"
  type        = string
}

variable "eks_cluster_domain" {
  description = "The domain for the EKS cluster"
  type        = string
  default     = ""
}

variable "eks_worker_security_group_id" {
  description = "EKS Worker Security group Id created by EKS module"
  default     = ""
  type        = string
}

variable "auto_scaling_group_names" {
  description = "List of self-managed node groups autoscaling group names"
  default     = []
  type        = list(string)
}

variable "node_groups_iam_role_arn" {
  type        = list(string)
  default     = []
  description = "Node Groups IAM role ARNs"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "irsa_iam_role_path" {
  type        = string
  default     = "/"
  description = "IAM role path for IRSA roles"
}

variable "irsa_iam_permissions_boundary" {
  description = "IAM permissions boundary for IRSA roles"
  type        = string
  default     = ""
}

variable "eks_oidc_provider" {
  description = "The OpenID Connect identity provider (issuer URL without leading `https://`)"
  type        = string
  default     = null
}

variable "eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
  default     = null
}

variable "eks_cluster_version" {
  description = "The Kubernetes version for the cluster"
  type        = string
  default     = null
}

#-----------EKS MANAGED ADD-ONS------------
variable "enable_ipv6" {
  description = "Enable Ipv6 network. Attaches new VPC CNI policy to the IRSA role"
  default     = false
  type        = bool
}

variable "amazon_eks_vpc_cni_config" {
  description = "ConfigMap of Amazon EKS VPC CNI add-on"
  type        = any
  default     = {}
}

variable "amazon_eks_coredns_config" {
  description = "ConfigMap for Amazon CoreDNS EKS add-on"
  type        = any
  default     = {}
}

variable "amazon_eks_kube_proxy_config" {
  description = "ConfigMap for Amazon EKS Kube-Proxy add-on"
  type        = any
  default     = {}
}

variable "amazon_eks_aws_ebs_csi_driver_config" {
  description = "configMap for AWS EBS CSI Driver add-on"
  type        = any
  default     = {}
}

variable "enable_amazon_eks_vpc_cni" {
  type        = bool
  default     = false
  description = "Enable VPC CNI add-on"
}

variable "enable_amazon_eks_coredns" {
  type        = bool
  default     = false
  description = "Enable CoreDNS add-on"
}

variable "enable_amazon_eks_kube_proxy" {
  type        = bool
  default     = false
  description = "Enable Kube Proxy add-on"
}

variable "enable_amazon_eks_aws_ebs_csi_driver" {
  description = "Enable EKS Managed AWS EBS CSI Driver add-on"
  type        = bool
  default     = false
}

variable "custom_image_registry_uri" {
  description = "Custom image registry URI map of `{region = dkr.endpoint }`"
  type        = map(string)
  default     = {}
}

#-----------CLUSTER AUTOSCALER-------------
variable "enable_cluster_autoscaler" {
  type        = bool
  default     = false
  description = "Enable Cluster autoscaler add-on"
}

variable "cluster_autoscaler_helm_config" {
  description = "Cluster Autoscaler Helm Chart config"
  type        = any
  default     = {}
}

#-----------COREDNS AUTOSCALER-------------
variable "enable_coredns_autoscaler" {
  description = "Enable CoreDNS autoscaler add-on"
  type        = bool
  default     = false
}

variable "coredns_autoscaler_helm_config" {
  description = "CoreDNS Autoscaler Helm Chart config"
  type        = any
  default     = {}
}

#-----------Crossplane ADDON-------------
variable "enable_crossplane" {
  type        = bool
  default     = false
  description = "Enable Crossplane add-on"
}

variable "crossplane_helm_config" {
  type        = any
  default     = null
  description = "Crossplane Helm Chart config"
}

variable "crossplane_aws_provider" {
  description = "AWS Provider config for Crossplane"
  type = object({
    enable                   = bool
    provider_aws_version     = string
    additional_irsa_policies = list(string)
  })
  default = {
    enable                   = false
    provider_aws_version     = "v0.24.1"
    additional_irsa_policies = []
  }
}

variable "crossplane_jet_aws_provider" {
  description = "AWS Provider Jet AWS config for Crossplane"
  type = object({
    enable                   = bool
    provider_aws_version     = string
    additional_irsa_policies = list(string)
  })
  default = {
    enable                   = false
    provider_aws_version     = "v0.24.1"
    additional_irsa_policies = []
  }
}

#-----------External DNS ADDON-------------
variable "enable_external_dns" {
  type        = bool
  default     = false
  description = "External DNS add-on."
}

variable "external_dns_helm_config" {
  type        = any
  default     = {}
  description = "External DNS Helm Chart config"
}

variable "external_dns_irsa_policies" {
  type        = list(string)
  description = "Additional IAM policies for a IAM role for service accounts"
  default     = []
}

#-----------Amazon Managed Service for Prometheus-------------
variable "enable_amazon_prometheus" {
  type        = bool
  default     = false
  description = "Enable AWS Managed Prometheus service"
}

variable "amazon_prometheus_workspace_endpoint" {
  type        = string
  default     = null
  description = "AWS Managed Prometheus WorkSpace Endpoint"
}

#-----------PROMETHEUS-------------
variable "enable_prometheus" {
  description = "Enable Community Prometheus add-on"
  type        = bool
  default     = false
}

variable "prometheus_helm_config" {
  description = "Community Prometheus Helm Chart config"
  type        = any
  default     = {}
}

#-----------METRIC SERVER-------------
variable "enable_metrics_server" {
  type        = bool
  default     = false
  description = "Enable metrics server add-on"
}

variable "metrics_server_helm_config" {
  type        = any
  default     = {}
  description = "Metrics Server Helm Chart config"
}

#-----------TETRATE ISTIO-------------
variable "enable_tetrate_istio" {
  type        = bool
  default     = false
  description = "Enable Tetrate Istio add-on"
}

variable "tetrate_istio_distribution" {
  type        = string
  default     = "TID"
  description = "Istio distribution"
}

variable "tetrate_istio_version" {
  type        = string
  default     = ""
  description = "Istio version"
}

variable "tetrate_istio_install_base" {
  type        = bool
  default     = true
  description = "Install Istio `base` Helm Chart"
}

variable "tetrate_istio_install_cni" {
  type        = bool
  default     = true
  description = "Install Istio `cni` Helm Chart"
}

variable "tetrate_istio_install_istiod" {
  type        = bool
  default     = true
  description = "Install Istio `istiod` Helm Chart"
}

variable "tetrate_istio_install_gateway" {
  type        = bool
  default     = true
  description = "Install Istio `gateway` Helm Chart"
}

variable "tetrate_istio_base_helm_config" {
  type        = any
  default     = {}
  description = "Istio `base` Helm Chart config"
}

variable "tetrate_istio_cni_helm_config" {
  type        = any
  default     = {}
  description = "Istio `cni` Helm Chart config"
}

variable "tetrate_istio_istiod_helm_config" {
  type        = any
  default     = {}
  description = "Istio `istiod` Helm Chart config"
}

variable "tetrate_istio_gateway_helm_config" {
  type        = any
  default     = {}
  description = "Istio `gateway` Helm Chart config"
}

#-----------TRAEFIK-------------
variable "enable_traefik" {
  type        = bool
  default     = false
  description = "Enable Traefik add-on"
}

variable "traefik_helm_config" {
  type        = any
  default     = {}
  description = "Traefik Helm Chart config"
}

#-----------AGONES-------------
variable "enable_agones" {
  type        = bool
  default     = false
  description = "Enable Agones GamServer add-on"
}

variable "agones_helm_config" {
  type        = any
  default     = {}
  description = "Agones GameServer Helm Chart config"
}

#-----------AWS EFS CSI DRIVER ADDON-------------
variable "enable_aws_efs_csi_driver" {
  type        = bool
  default     = false
  description = "Enable AWS EFS CSI driver add-on"
}

variable "aws_efs_csi_driver_helm_config" {
  type        = any
  description = "AWS EFS CSI driver Helm Chart config"
  default     = {}
}

#-----------AWS LB Ingress Controller-------------
variable "enable_aws_load_balancer_controller" {
  type        = bool
  default     = false
  description = "Enable AWS Load Balancer Controller add-on"
}

variable "aws_load_balancer_controller_helm_config" {
  type        = any
  description = "AWS Load Balancer Controller Helm Chart config"
  default     = {}
}

#-----------NGINX-------------
variable "enable_ingress_nginx" {
  type        = bool
  default     = false
  description = "Enable Ingress Nginx add-on"
}

variable "ingress_nginx_helm_config" {
  description = "Ingress Nginx Helm Chart config"
  type        = any
  default     = {}
}

#-----------SPARK K8S OPERATOR-------------
variable "enable_spark_k8s_operator" {
  type        = bool
  default     = false
  description = "Enable Spark on K8s Operator add-on"
}

variable "spark_k8s_operator_helm_config" {
  description = "Spark on K8s Operator Helm Chart config"
  type        = any
  default     = {}
}

#-----------AWS FOR FLUENT BIT-------------
variable "enable_aws_for_fluentbit" {
  description = "Enable AWS for FluentBit add-on"
  type        = bool
  default     = false
}

variable "aws_for_fluentbit_helm_config" {
  description = "AWS for FluentBit Helm Chart config"
  type        = any
  default     = {}
}

variable "aws_for_fluentbit_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "aws_for_fluentbit_create_cw_log_group" {
  description = "Set to false to use existing CloudWatch log group supplied via the cw_log_group_name variable."
  type        = bool
  default     = true
}

variable "aws_for_fluentbit_cw_log_group_name" {
  description = "FluentBit CloudWatch Log group name"
  type        = string
  default     = null
}

variable "aws_for_fluentbit_cw_log_group_retention" {
  description = "FluentBit CloudWatch Log group retention period"
  type        = number
  default     = 90
}

variable "aws_for_fluentbit_cw_log_group_kms_key_arn" {
  description = "FluentBit CloudWatch Log group KMS Key"
  type        = string
  default     = null
}

#-----------FARGATE FLUENT BIT-------------
variable "enable_fargate_fluentbit" {
  type        = bool
  default     = false
  description = "Enable Fargate FluentBit add-on"
}

variable "fargate_fluentbit_addon_config" {
  type        = any
  description = "Fargate fluentbit add-on config"
  default     = {}
}

#-----------CERT MANAGER-------------
variable "enable_cert_manager" {
  type        = bool
  default     = false
  description = "Enable Cert Manager add-on"
}

variable "cert_manager_helm_config" {
  type        = any
  description = "Cert Manager Helm Chart config"
  default     = {}
}

variable "cert_manager_irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "cert_manager_domain_names" {
  description = "Domain names of the Route53 hosted zone to use with cert-manager"
  type        = list(string)
  default     = []
}

variable "cert_manager_install_letsencrypt_issuers" {
  description = "Install Let's Encrypt Cluster Issuers"
  type        = bool
  default     = true
}

variable "cert_manager_letsencrypt_email" {
  description = "Email address for expiration emails from Let's Encrypt"
  type        = string
  default     = ""
}

#-----------Argo Rollouts ADDON-------------
variable "enable_argo_rollouts" {
  type        = bool
  default     = false
  description = "Enable Argo Rollouts add-on"
}

variable "argo_rollouts_helm_config" {
  type        = any
  default     = null
  description = "Argo Rollouts Helm Chart config"
}

#-----------ARGOCD ADDON-------------
variable "enable_argocd" {
  type        = bool
  default     = false
  description = "Enable Argo CD Kubernetes add-on"
}

variable "argocd_helm_config" {
  type        = any
  default     = {}
  description = "Argo CD Kubernetes add-on config"
}

variable "argocd_applications" {
  type        = any
  default     = {}
  description = "Argo CD Applications config to bootstrap the cluster"
}

variable "argocd_admin_password_secret_name" {
  type        = string
  default     = ""
  description = "Name for a secret stored in AWS Secrets Manager that contains the admin password."
}

variable "argocd_manage_add_ons" {
  type        = bool
  default     = false
  description = "Enable managing add-on configuration via ArgoCD"
}

#-----------AWS NODE TERMINATION HANDLER-------------
variable "enable_aws_node_termination_handler" {
  type        = bool
  default     = false
  description = "Enable AWS Node Termination Handler add-on"
}

variable "aws_node_termination_handler_helm_config" {
  type        = any
  description = "AWS Node Termination Handler Helm Chart config"
  default     = {}
}

variable "aws_node_termination_handler_irsa_policies" {
  type        = list(string)
  description = "Additional IAM policies for a IAM role for service accounts"
  default     = []
}

#-----------KARPENTER ADDON-------------
variable "enable_karpenter" {
  type        = bool
  default     = false
  description = "Enable Karpenter autoscaler add-on"
}

variable "karpenter_helm_config" {
  type        = any
  default     = {}
  description = "Karpenter autoscaler add-on config"
}

variable "karpenter_irsa_policies" {
  type        = list(string)
  description = "Additional IAM policies for a IAM role for service accounts"
  default     = []
}

variable "karpenter_node_iam_instance_profile" {
  description = "Karpenter Node IAM Instance profile id"
  default     = ""
  type        = string
}

#-----------KEDA ADDON-------------
variable "enable_keda" {
  type        = bool
  default     = false
  description = "Enable KEDA Event-based autoscaler add-on"
}

variable "keda_helm_config" {
  type        = any
  default     = {}
  description = "KEDA Event-based autoscaler add-on config"
}

variable "keda_irsa_policies" {
  type        = list(string)
  description = "Additional IAM policies for a IAM role for service accounts"
  default     = []
}

#-----------Kubernetes Dashboard ADDON-------------
variable "enable_kubernetes_dashboard" {
  type        = bool
  default     = false
  description = "Enable Kubernetes Dashboard add-on"
}

variable "kubernetes_dashboard_helm_config" {
  type        = any
  default     = null
  description = "Kubernetes Dashboard Helm Chart config"
}

variable "kubernetes_dashboard_irsa_policies" {
  type        = list(string)
  default     = []
  description = "IAM policy ARNs for Kubernetes Dashboard IRSA"
}

#------Vertical Pod Autoscaler(VPA) ADDON--------
variable "enable_vpa" {
  type        = bool
  default     = false
  description = "Enable Vertical Pod Autoscaler add-on"
}

variable "vpa_helm_config" {
  type        = any
  default     = null
  description = "VPA Helm Chart config"
}

#-----------Apache YuniKorn ADDON-------------
variable "enable_yunikorn" {
  type        = bool
  default     = false
  description = "Enable Apache YuniKorn K8s scheduler add-on"
}

variable "yunikorn_helm_config" {
  type        = any
  default     = null
  description = "YuniKorn Helm Chart config"
}

variable "yunikorn_irsa_policies" {
  type        = list(string)
  default     = []
  description = "IAM policy ARNs for Yunikorn IRSA"
}

#-----------AWS CSI Secrets Store Provider-------------
variable "enable_secrets_store_csi_driver_provider_aws" {
  type        = bool
  default     = false
  description = "Enable AWS CSI Secrets Store Provider"
}

variable "csi_secrets_store_provider_aws_helm_config" {
  type        = any
  default     = null
  description = "CSI Secrets Store Provider AWS Helm Configurations"
}

#-----------CSI Secrets Store Provider-------------
variable "enable_secrets_store_csi_driver" {
  type        = bool
  default     = false
  description = "Enable CSI Secrets Store Provider"
}

variable "secrets_store_csi_driver_helm_config" {
  type        = any
  default     = null
  description = "CSI Secrets Store Provider Helm Configurations"
}
terraform {
    required_version = ">= 1.0"
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "~> 4.0"
        }
    }
}

provider "google" {
    project = var.project_id
    region = var.region
    zone = var.zone
}

module "vpc" {
    source   = "./module/vpc"
    vpc_name = "prod-vpc"
    subnet_name = "prod-subnet"
    subnet_cidr = "10.10.0.0/24"
    region = var.region
}

module "artifact_registry" {
  source             = "./modules/artifact_registry"
  repo_name          = "devsecops-playground-docker-repo"
  repository_project = var.project_id
  location           = var.region
}

module "firewall" {
  source      = "./modules/firewall"
  network     = module.vpc.network_name
  allow_rules = [
    {
      name        = "allow-ssh"
      description = "Allow SSH on port 22"
      protocol    = "tcp"
      ports       = ["22"]
      source_ips  = ["0.0.0.0/0"]
      target_tags = ["ssh-allowed"]
    },
    {
      name        = "allow-juice-shop"
      description = "Allow inbound traffic on port 3000"
      protocol    = "tcp"
      ports       = ["3000"]
      source_ips  = ["0.0.0.0/0"]
      target_tags = ["juice-shop"]
    }
  ]
}

module "juice_shop_instance" {
  source                = "./modules/instance"
  instance_name         = "juice-shop-vm"
  machine_type          = "e2-micro"
  zone                  = var.zone
  subnetwork            = module.vpc.subnet_name
  network_tags          = ["juice-shop", "ssh-allowed"]
  # Pass in the Docker image from Artifact Registry
  docker_image          = "${var.region}-docker.pkg.dev/${var.project_id}/${module.artifact_registry.repository_name}/juice-shop:latest"
  container_port        = 3000
}
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  # Опционально: Состояние Terraform можно хранить в GCS Bucket
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "gamestatshub/terraform/state"
  # }
}

provider "google" {
  project = var.gcp_project
  region  = var.region
  zone    = var.zone
}

# Создание VPC сети и firewall правила
resource "google_compute_network" "vpc_network" {
  name                    = "gamestatshub-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "gamestatshub-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "ssh_http" {
  name    = "allow-ssh-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "5001"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gamestatshub-server"]
}

# Создание виртуальной машины
resource "google_compute_instance" "vm_instance" {
  name         = "gamestatshub-prod"
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["gamestatshub-server"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.vpc_subnet.name
    access_config {
      # Оставляет внешний IP пустым
      network_tier = "STANDARD"
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_path)}"
  }

  # Ключевой момент: запуск Ansible после создания ВМ
  provisioner "remote-exec" {
    inline = ["echo 'VM is ready for Ansible'"]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_priv_key_path)
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

# Output внешнего IP адреса сервера
output "server_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

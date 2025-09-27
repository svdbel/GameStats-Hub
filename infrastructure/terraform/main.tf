terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

}

provider "google" {
  project = "gamestats-473407"
  region  = var.region
  zone    = var.zone
}

# =============== ШАГ 1: Включаем необходимые API ===============
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "oslogin.googleapis.com"
  ])

  project                    = "gamestatshub-472706"
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}

# =============== ШАГ 2: Создаём VPC и подсеть ===============
resource "google_compute_network" "vpc_network" {
  name                    = "gamestatshub-vpc"
  auto_create_subnetworks = false

  depends_on = [google_project_service.required_apis]
}

resource "google_compute_subnetwork" "vpc_subnet" {
  name          = "gamestatshub-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id

  depends_on = [google_compute_network.vpc_network]
}

# ---
## ШАГ 3: Создаём статические IP
# ---

# =============== 3.1: Статический IP для Prod-VM ===============
resource "google_compute_address" "static_ip_prod" {
  name   = "gamestatshub-static-ip-prod"
  region = var.region

  depends_on = [google_project_service.required_apis]
}

# =============== 3.2: Статический IP для Backup-VM 🆕 ===============
resource "google_compute_address" "static_ip_backup" {
  name   = "gamestatshub-static-ip-backup"
  region = var.region

  depends_on = [google_project_service.required_apis]
}

# ---
## ШАГ 4: Firewall правила
# ---
resource "google_compute_firewall" "ssh_http" {
  name    = "allow-ssh-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  # 🔐 ОПЦИОНАЛЬНО: ограничь SSH только своим IP для безопасности
  # source_ranges = ["YOUR_IP/32"]   # ← Раскомментируй и замени YOUR_IP
  source_ranges = ["0.0.0.0/0"] # ← Сейчас разрешено всем (для теста)

  target_tags = ["gamestatshub-server", "gamestatshub-backup"]

  depends_on = [google_compute_network.vpc_network]
}

# ---
## ШАГ 5: Создаём ВМ
# ---

# =============== 5.1: Основная ВМ (Prod) ===============
resource "google_compute_instance" "vm_instance" {
  name         = "gamestatshub-prod"
  machine_type = "e2-medium"
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
      nat_ip = google_compute_address.static_ip_prod.address # ← Используем статический IP Prod
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'VM is ready for Ansible'",
      "sudo apt-get update && sudo apt-get install -y python3"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_priv_key_path)
      host        = google_compute_address.static_ip_prod.address
    }
  }

  depends_on = [
    google_compute_address.static_ip_prod,
    google_compute_firewall.ssh_http
  ]
}

# =============== 5.2: Бэкап ВМ (Backup) ===============
resource "google_compute_instance" "vm_backup_instance" {
  name         = "gamestatshub-backup"
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["gamestatshub-backup"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.vpc_subnet.name
    access_config {
      nat_ip = google_compute_address.static_ip_backup.address # 💡 Назначаем статический IP для Backup!
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Backup VM is ready'",
      "sudo apt-get update && sudo apt-get install -y rsync"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_priv_key_path)
      # Используем назначенный внешний IP для подключения
      host = google_compute_address.static_ip_backup.address
    }
  }

  depends_on = [
    google_compute_address.static_ip_backup, # Новая зависимость
    google_compute_firewall.ssh_http
  ]
}

# ---
## OUTPUT
# ---
output "server_public_ip_prod" {
  description = "Статический внешний IP-адрес основного сервера"
  value       = google_compute_address.static_ip_prod.address
}

output "server_internal_ip_prod" {
  description = "Внутренний IP-адрес основного сервера"
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
}

output "server_public_ip_backup" {
  description = "Статический внешний IP-адрес бэкап-сервера 🆕"
  value       = google_compute_address.static_ip_backup.address
}

output "server_internal_ip_backup" {
  description = "Внутренний IP-адрес бэкап-сервера"
  value       = google_compute_instance.vm_backup_instance.network_interface[0].network_ip
}

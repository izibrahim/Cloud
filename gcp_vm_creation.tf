# GCP vm machine
provider "google" {
  credentials = file("gcpuser.json")
  project     = "my-project-7214-246815"
  region      = "us-west4"
  zone        =  "us-west4-a"
}
resource "google_project_service" "api" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com"
  ])
  disable_on_destroy = false
  service            = each.value
}

resource "google_compute_firewall" "web" {
  name          = "web-access"
  network       = "default"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_instance" "my_web_server" {
  name         = "my-gcp-web-server"
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9" // Image to use for VM
    }
  }
  network_interface {
    network = "default" // This Enable Private IP Address
    access_config {}    // This Enable Public IP Address
  }
  metadata_startup_script= <<EOF
 #! /bin/bash
 sudo apt update -y
 sudo apt install apache2 -y
 sudo chmod 7777 -R /var/www/html
 sudo echo "<h2>WebServer on GCP Build by Terraform!<h2>"  >  /var/www/html/index.html
 sudo chmod 7777 -R /var/www/html
 sudo systemctl enable apache2
 sudo systemctl restart apache2
EOF

  depends_on = [google_project_service.api, google_compute_firewall.web]
}

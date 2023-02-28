provider "google" {
  project = "summer2021-319316"
  region  = "europe-west4-a"
}

resource "google_container_cluster" "primary" {
  name               = "visma-demo"
  location           = "europe-west4-a"
  initial_node_count = 3

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    ]
    disk_size_gb = 20
  }
  timeouts {
    create = "30m"
    update = "40m"
  }
}

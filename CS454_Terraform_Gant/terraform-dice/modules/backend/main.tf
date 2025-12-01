terraform {                          # Terraform Config block 
  required_providers {               # Declares the provider required for the configuration
    docker = {                       # Configures the docker environment
      source  = "kreuzwerker/docker" # Provides source provider in the Terraform Registry
      version = "~> 3.0"             # Sets the version
    } 
  }
}

variable "Network_Name" {            # Docker network name passed from root
  type = string
}

variable "External_Port" {           # Host port for the backend API (5001)
  type = number
}

resource "docker_image" "backend" {  # Builds the backend image from /backend
  name = "dice-backend:latest"

  build {
    context    = "${path.module}/../../backend"
    dockerfile = "${path.module}/../../backend/Dockerfile"
  }
}

resource "docker_container" "backend" { # Backend API container
  name  = "dice-backend"
  image = docker_image.backend.image_id

  networks_advanced {                 # Attach to the shared app network
    name = var.Network_Name
  }

  ports {                             # Map container 5000 -> host External_Port
    internal = 5000
    external = var.External_Port
  }
}


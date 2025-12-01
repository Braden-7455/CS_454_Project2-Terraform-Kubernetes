terraform {                          #Terraform Config block 
  required_providers {               #Declares the provider required for the configuration
    docker = {                       #Configures the docker environment
      source  = "kreuzwerker/docker" #Provides source provider in the Terraform Registry
      version = "~> 3.0"             #Sets the version
    } 
  }
}


provider "docker" {                    #Confiures the Docker Provider
  host = "unix:///var/run/docker.sock" #Connects to the Docker using a Unix socket
}

resource "docker_network" "app_net" {  #Creates a Custom Docker Network for the app stack 
  name = "dice_app_net"                #Name of the docker network
}

module "db" {                                 #initiates the Postgres module 
  source       = "./modules/db"               #Sets the directory path
  Network_Name = docker_network.app_net.name  #Passes tge Docker network name into the database module

  Database_User     = var.Database_User
  Database_Password = var.Database_Password
  Database_Name     = var.Database_Name
}

module "backend" {
  source        = "./modules/backend"
  Network_Name  = docker_network.app_net.name   #sets the backend containers to the same network
  External_Port = 5001                          #Hosts the external port to the backend API
}

module "frontend" {
  source        = "./modules/frontend"          #Initiates the fronted module
  Network_Name  = docker_network.app_net.name   #Attaches the frontend container to (Nginx/UI) module 
  External_Port = 8080                          #Exposes the frontend website on port 8080
}

output "Frontend_URL" {                         #Outputs a URL for the frontend
  value = "http://localhost:8080"               #Sets the frontend for port 8080 on the local machine
}

output "Backend_URL" {                          #Outputs an example URL for the backend API
  value = "http://localhost:5001/roll?die=d20"  #Backend endpoint for rolling a d20 on port 5001
}

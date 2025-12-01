terraform {                          #Terraform Config block 
  required_providers {               #Declares the provider required for the configuration
    docker = {                       #Configures the docker environment
      source  = "kreuzwerker/docker" #Provides source provider in the Terraform Registry
      version = "~> 3.0"             #Sets the version
    } 
  }
}

variable "Network_Name" {           #Declares a variable named Network_Name
  type = string                     #Sets the type of the variable to string
}

variable "External_Port" {          #Declares a variable named External_Port
  type = number                     #Sets the type of the variable to a number             
}

resource "docker_image" "frontend" { #Builds the frontend docker image
  name = "dice-frontend:latest"      #Sets the tag name for the image

  build {
    context    = "${path.module}/../../frontend"              #Builds the context directory
    dockerfile = "${path.module}/../../frontend/Dockerfile"   #Sets the path for the dockerfile
  }
}

resource "docker_container" "frontend" {    
  name  = "dice-frontend"                   
  image = docker_image.frontend.image_id    

  networks_advanced {
    name = var.Network_Name       #Sets tge name of the netwrok from the Network_Name variable
  }

  ports {                         #Maps the portst from the host to the container
    internal = 80                 #Sets the container port for nginx to 80
    external = var.External_Port  #Set the Host port using the External_Port var
  }
}



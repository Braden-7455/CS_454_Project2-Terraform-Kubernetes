terraform {                          #Terraform Config block 
  required_providers {               #Declares the provider required for the configuration
    docker = {                       #Configures the docker environment
      source  = "kreuzwerker/docker" #Provides source provider in the Terraform Registry
      version = "~> 3.0"             #Sets the version
    } 
  }
}

variable "Network_Name" {            #Declares a variable named Network_Name
  type = string                      #Sets the type of the variable to string
}

variable "Database_User" {           #Sets the variable Database_User 
  type = string                      #Sets the type of the variable to string 
}

variable "Database_Password" {       #Declares a variable named Database_Password
  type      = string                 #Sets the type of the variable to string
  sensitive = true                   #Marks it as sensitive so it is not shown in plain text
}

variable "Database_Name" {           #Declares a variable named Database_Name
  type = string                      #Sets the type of the variable to string
}

resource "docker_image" "postgres" {             #Defines the Postgres Docker image
  name = "postgres:16-alpine"                    #Image name and tag
}

resource "docker_volume" "postgres_data" {       #Creates a Docker volume for Postgres data
  name = "dice_postgres_data"                    #Name of the docker volume
}

resource "docker_container" "postgres" {         #Defines the Postgres container
  name  = "dice-postgres"                        #Name of the container
  image = docker_image.postgres.image_id         #Uses the image from the docker_image

  networks_advanced {                            #Attach container to the specified Docker network
    name = var.Network_Name                      #Uses the Network_Name variable (case-sensitive)
  }

  env = [                                        #Sets environment variables for Postgres
    "POSTGRES_USER=${var.Database_User}",        #Sets the Postgres username
    "POSTGRES_PASSWORD=${var.Database_Password}",#Sets the Postgres password
    "POSTGRES_DB=${var.Database_Name}",          #Creates the database on startup
  ]

  mounts {                                       #Mounts the Docker volume into the container
    target = "/var/lib/postgresql/data"          #Path inside the container for Postgres data
    source = docker_volume.postgres_data.name    #Uses the named Docker volume defined above
    type   = "volume"                            #Mount type for the Docker-managed volume
  }

  ports {                                        #Exposes Postgres on the host
    internal = 5432                              #Default Postgres port inside the container
    external = 5432                              #Exposes the same port on the host machine
  }
}

output "container_name" {                        #Outputs the name of the Postgres container
  value = docker_container.postgres.name         #Returns "dice-postgres"
}



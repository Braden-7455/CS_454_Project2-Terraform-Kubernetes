variable "namespace_name" {     #Sets the name of the Kubernetes namespace
  type        = string          #Sets  the variable as a string type
  description = "Kubernetes namespace for the dice app"
  default     = "dice-app"      #dice app is defaul namespace
}

variable "app_image" {          #Docker image is set for the dice backend container
  type        = string          #Sets  the variable as a string type
  description = "Container image for the dice backend"
  default     = "dice-backend:latest"
}

variable "replicas" {          #Sets the number of replicas for the backend deployment
  type        = number         #Sets  the variable as a num type
  description = "Number of pod replicas for the Deployment"
  default     = 1              #Runs a single pod by default, can be changed for more pods
}

variable "service_node_port" { #Sets the Nodeport fo which the service will be exposed on
  type        = number         #Sets  the variable as a num type
  description = "NodePort exposed on the kind node (localhost)"
  default     = 30001          #Default NodePort used to reach the backend
}

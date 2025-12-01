terraform {             #Terraform configuaration
  required_providers {  #Declares the external prociders
    kubernetes = {      #Specifies the offivial Hoshicorp Kubernetes provider
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

provider "kubernetes" {
  # Use the same kubeconfig file kubectl uses   #Configures the Kubernetes provider
  config_path = "C:/Users/Braden/.kube/config"  #Sets the path to the local Kubeconfig
  # current-context will be used 
}

# *****Namespace*****

resource "kubernetes_namespace" "dice" { #Creates the dedicated namespace for the dice application
  metadata {
    name = var.namespace_name 
  }
}

# *****Enhancement: ConfigMap*****

resource "kubernetes_config_map" "dice_settings" {  #Sets the Config Map for app level settings
  metadata {
    name      = "dice-settings"                             #Sets the name of the config map
    namespace = kubernetes_namespace.dice.metadata[0].name  #Sets the place in the dice namespace
  }

  data = {                #Key values will pair and store them in the config map
    DEFAULT_DIE = "d20"   #Default die used fir the Enhancement
    APP_NAME    = "Terraform Dice Demo" #Sets the display name for the app
  }
}


# *****Deployment: Dice-Backend*****

resource "kubernetes_deployment" "dice_app" { #Sets the Deployment for the backend application
  metadata {
    name      = "dice-backend"  #Sets the name of the deployment
    namespace = kubernetes_namespace.dice.metadata[0].name  #Deploys it into the namespace
    labels = {
      app = "dice-backend"    #Sets a common label for the Deployment
    }
  }

  spec {
    replicas = var.replicas #Sets the number of pod replicas from the variables

    selector {              #Selects goe the deployment finds the pods and manages them
      match_labels = {  
        app = "dice-backend"  #Must match the pod template labels
      }
    }

    template {      #Sets the pod template
      metadata {
        labels = {
          app = "dice-backend"    #Label thats applied tothe backend
        }
      }

      spec {
        container {                         #Sets the specs for each pod
          name  = "dice-backend"            #Sets the container name
          image = var.app_image             #Sets the docker image

          image_pull_policy = "IfNotPresent"  #Will use the local image if available

          #Flask app listens on port 5000 inside the container
          port {
            container_port = 5000 #Exposes the port 5000 on the container/pod
          }

          # *****Enhancement***** Inject DEFAULT_DIE from ConfigMap as an environmental variable
          env {
            name = "DEFAULT_DIE"    #Sets the environmental name variable for the inside of the container
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.dice_settings.metadata[0].name   #Refernce for the Copnfig map
                key  = "DEFAULT_DIE"    #Use the default of the die
              }
            }
          }
        }
      }
    }
  }
}

# *****Service: NodePort*****

resource "kubernetes_service" "dice_service" {  #This is the service to be exposed to the backed
  metadata {
    name      = "dice-backend-service"                     #Sets the name for the service 
    namespace = kubernetes_namespace.dice.metadata[0].name #Sets to te same namespace for the deploymen
  }

  spec {
    selector = {
      app = "dice-backend"  #Routes the traffic to the pod
    }

    port {
      port        = 5000                      #Services the port inside the cluster
      target_port = 5000                      #Target for the pod/container
      node_port   = var.service_node_port     #Exposes the Nodepoer on the cluster node
    }

    type = "NodePort"     #Exposes the service externally using the NodePort
  }
}

# *****Outputs*****

output "namespace" {      #Sets the otuput name for the app
  value = kubernetes_namespace.dice.metadata[0].name
}

output "dice_backend_url" {   #Ouputs for the URL for testing the dice API
  value = "http://localhost:${var.service_node_port}/roll?die=d20"
}

variable "Database_User" {          #Declares a variable named Database_User
  type        = string              #Sets the type of the variable to string
  description = "Postgres Username" #Sets the Description for the variable
}

variable "Database_Password" {      #Declares a variable named Database_Password
  type        = string              #Sets the type of the variable to string
  sensitive   = true                #Sets it as sensitive so it is not shown in plain text within outputs and logs
  description = "Postgres Password" #Sets the Description for the variable
}

variable "Database_Name" {               #Declares a variable named Database_Name
  type        = string                   #Sets the type of the variable to string
  description = "Postgres Database Name" #Sets the Description for the variable
}

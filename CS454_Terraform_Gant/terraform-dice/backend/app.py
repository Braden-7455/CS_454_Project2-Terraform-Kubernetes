# ****************************************************************************************************
# Program Title: Terraform Dice Roller 
# Project File: app.py
# Name: Braden Gant
# Course Section: CS454-01
# Due Date: 12/01/2025 
# ****************************************************************************************************
# ******************************* PROGRAM DESCRIPTION ************************************************
# ****************************************************************************************************
# This program implements a simple REST Dice Roller API using Flask. Clients send GET
# requests to the /roll endpoint with a "die" query (e.g., d6, d20, 3d6, or 6).
# The server then validates the input, performs the dice rolls using the random funct,
# and then returns the individual results and total as JSON. A root ("/") endpoint is also
# provided as a basic health/status check. CORS is enabled to allow requests from any
# origin so a separate frontend for running in a browser etc... is able to access this API.
# ****************************************************************************************************


from flask import Flask, request, jsonify
import random           #Imports random for dice rolls

app = Flask(__name__)   #Creates a bew Flask instance

@app.after_request      #Sets a function to run after each request
def add_cors_headers(response): #This function adds the CORS header to each response
    response.headers["Access-Control-Allow-Origin"] = "*" #Allows for requests from any origin (CORS)
    return response         #returns the modified response

@app.route("/roll", methods=["GET"]) #Defines a GET endpoint for /roll
def roll():     #Handles the function for the /roll 
    """
    Query params:
      die = "d6", "d20", "3d6", or just "6"    
    """ #Defines the query params

    die_param = request.args.get("die", "d6").lower().strip()   #Reads the die from the qyuery and converts it to lowerspace etc....

    count = 1   #Sets the defould count
    sides = 6   #Sets the default dice

    try:                                    #Tries to pares the parameter
        if "d" in die_param:                #Checks to see if d is in the parameter
            parts = die_param.split("d")
            if parts[0] == "":      #If nothing then default count = 1
                count = 1           #Default count = 1
            else:
                count = int(parts[0])       #Converts the count to an int
            sides = int(parts[1])           #Converts the sides into an int
        else:
            sides = int(die_param)  #IF there is no d then the entire value is treated as single die
    except ValueError:
        return jsonify(error="Invalid die format. Use like d6, d20, 3d6, or 6"), 400    #If inccorrect input then output Invalid die format Error = 400

    if count <= 0 or count > 100:   #Checks to see if the the number od dice to roll falls between 1 & 100,  Error = 400
        return jsonify(error="count must be between 1 and 100"), 400
    
    if sides <= 0 or sides > 1000:  #Checks to see if the number of side of the fice falls between 1 and 1000, Error = 400
        return jsonify(error="sides must be between 1 and 1000"), 400

    rolls = [random.randint(1, sides) for _ in range(count)]        #Generates random integers between 1 and the number of sides
    total = sum(rolls)  #Computes the total sum of the dice rolls

    return jsonify(             #Returns all of the dice data in a JSON format
        die=f"{count}d{sides}",
        count=count,
        sides=sides,
        results=rolls,
        total=total,
    )

@app.route("/", methods=["GET"])        #Defines the GET endpoint fot the root URL                        
def root():                                                 #Handles tje root
    return jsonify(message="Dice API up. Use /roll?die=d20"), 200 #Returns a JSON status message
                                      #HTTP 200 is status message OK

if __name__ == "__main__":                  #If script is executed it runs this 
    app.run(host="0.0.0.0", port=5000)      #Starts the Flask server on port 5000
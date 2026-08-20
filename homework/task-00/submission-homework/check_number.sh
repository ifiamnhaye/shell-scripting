#!/bin/bash

echo
read -r -p "enter the number: " number  # Prompt the user for input and store it in variable 'number'



# Check if input matches a whole number (optional + or - followed by digits)
if [[ ! "$number" =~ ^[+-]?[0-9]+$ ]]; then 
    echo "Error: enter a valid whole number." >&2  # Print error message to stderr
    exit 1  # Exit script with a failure status code
fi

# Compare the numerical value of the input
 if (( number > 0 )); then 
      echo "$number is positive."  # Executed if number is greater than 0
 elif (( number < 0 )); then
      echo "$number is negative."  # Executed if number is less than 0
 else
      echo "$number is zero."      # Executed if number equals 0
fi

exit 0  # Exit script with success status code


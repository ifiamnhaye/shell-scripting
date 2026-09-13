#!/bin/bash



read -r -p "Enter a starting number: " num

# Input validation
if [[ "$num" =~ ^[+-]?[0-9]+$ ]];
then
 echo "Starting infinite countdown"
    else
	    echo "Error: Please enter a valid integer."
		    exit 1
fi

# Infinite loop( while true ,while :,while (( 1 )).......
while ((1)); 
do
	    echo "$num"
	        ((num--))
		sleep 2
	    done

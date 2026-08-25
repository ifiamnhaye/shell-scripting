#!/bin/bash

read -r -p "Enter a filename or path: " filename

# Run the condition check
[[ -f "$filename" ]]
status=$? # Immediately capture the condition's exit status (0 = true, 1 = false)

if [[ $status -eq 0 ]]; then
	    echo "File exists."
	        echo "Condition status: $status"
		    exit 0
	    else
		        echo "Error: File does not exist." >&2
			    echo "Condition status: $status"
			        exit 1
fi

#!/bin/bash

# Check if an argument was passed
# Check if no positional argument ($1) was passed or if the argument is empty.
# -z checks if the string length is zero.

if [ -z "$1" ]; then
	echo "$0"  
	exit 1 # Exit the script with a status code of 1 to indicate an error occurred
fi

echo "Hello, $1!"  # This prints argument 1 value

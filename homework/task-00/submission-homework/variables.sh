#!/bin/bash

# Variables and Quoting
# Store and display a name and role for Ifrah

# Define string variables

NAME="Ifrah"
ROLE="DevOps Engineer"

# Print a greeting using double quotes to allow variable

echo "Hello, I am $NAME and I am a $ROLE."

echo
echo
echo

echo "Double quotes: Hello, $NAME"    # $NAME expands to "Ifrah"
echo 'Single quotes: Hello, $NAME'    # $NAME is printed literally as $NAME

# Exit the script with a success status code
exit 0

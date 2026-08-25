#!/bin/bash

# Service to check
service_name="nginx"

# Ask user for confirmation
read -p "Do you want to check the status of $service_name? (y/n): " answer

# Handle input
case "$answer" in
       	y|Y|YES|yes|Yes)    # User chose Yes
	       	# Display full output without opening a page
		systemctl status --no-pager "$service_name"
                # Test active status using exit status ($? = 0 means active)
		if systemctl is-active --quiet "$service_name"; then # check the status quietly
		        echo "$service_name is active." # if active print this statment
	           else
		        echo "$service_name is inactive." # not active print this statment 
                fi
	    ;;
        n|N|no|NO|No)   # User chose No
		echo "Skipped."
	    ;;
																		 *)   # Any other input
                echo "Error: Invalid rsponse "
            ;;
																
    esac #end case

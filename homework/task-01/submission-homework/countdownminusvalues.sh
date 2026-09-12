#!/bin/bash


read -r -p "Enter a number: " num

# Simple input validation
if [[ "$num" =~ ^[-][0-9]+$ ]];
then
	echo "Number is valid. Starting countdown.."
 else
	  echo "Please enter a negative number." 
							                                            exit 1
fi
# Countdown loop
while [ $num -le 0 ]; 
do
        echo $num
	((num++))
								                                            done

#!/bin/bash

#define a list of items like array
 
fruits=("apple" "banana" "orange" "guava" "grapes")
integer=1

for fruit in "${fruits[@]}"

do
	echo "fruit no $integer: $fruit"
	integer=$((integer+1))
done

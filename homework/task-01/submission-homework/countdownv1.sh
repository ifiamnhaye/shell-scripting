#!/bin/bash


# countdown v1

count=5

while [[ count -ge 0 ]]  
do
	echo " $count "
	count=$((count-1))

done

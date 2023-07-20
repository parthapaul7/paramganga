#!/bin/bash

# Display the warning message
echo "WARNING: Running this command will perform a critical operation."
echo "Are you sure you want to continue? (Type 'yes' to proceed)"

# Read the user's input
read confirmation

# Check if the user's input is 'yes' (case-insensitive)
if [[ "$confirmation" =~ ^[Yy][Ee][Ss]$ ]]; then
    	echo "Executing file deletinon..."

	keep_files=("POSCAR" "POTCAR" "INCAR" "job.sh" "KPOINTS" "debug.sh")
	for f in *; do
  		if [[ ! " ${keep_files[@]} " =~ " ${f} " ]]; then
    		\rm "$f"
  		fi
	done

else
    echo "Operation canceled."
fi

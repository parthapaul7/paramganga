#!/bin/bash

# Display the warning message
# exit if no POTCAR or INCAR
if [ ! -f POSCAR ] || [ ! -f INCAR ]; then
  echo "POSCAR or INCAR file not found. Exiting."
  exit 1
fi

# Read the user's input
echo "WARNING: Running this command will remove a lot of files"
echo "Are you sure you want to continue? (Type 'yes' to proceed)"
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

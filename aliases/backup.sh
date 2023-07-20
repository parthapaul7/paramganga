#!/bin/bash
cd /scratch/partha_pp.iitr/backup

git add .
echo "your commit message"
read msg

if [ -z "$name" ]; then
	msg ="commit on $(date)" 
fi

echo "$msg"
git commit -m "$msg"
git push
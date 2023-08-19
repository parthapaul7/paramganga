#!/bin/bash

# Function to check the job status
check_job_status() {
    local job_id=$1
    local status=$(qstat -f $job_id | awk '/job_state/{print $3}')
    echo "$status"
}

   
cd ./npt/$1

# Submit the first job (Replace 'your_first_job_script.sh' with your actual script)
echo "Submitting npt ..."
output=$(sbatch debug.sh)
job_id=$(echo "$output" | awk '{print $4}')
echo "Job ID: $job_id"

# Wait for the first job to complete
echo "Waiting for the npt to complete..."
while true; do
    status=$(check_job_status $job_id)
    if [ "$status" == "C" ]; then
        echo "The npt is completed."
        break
    elif [ "$status" == "R" ]; then
        echo "The npt is still running..."
    fi
    sleep 60  # Adjust the sleep time (in seconds) based on your job length and scheduler configuration
done

# Submit the second job (Replace 'your_second_job_script.sh' with your actual script)

cd ../../nvt/$1
cat ../../npt/$1/CONTCAR > POSCAR

echo "Submitting the nvt ....."
output=$(sbatch debug.sh)
job_id=$(echo "$output" | awk '{print $4}')
echo "Job ID: $job_id"

echo "Waiting for the nvt to complete..."
while true; do
    status=$(check_job_status $job_id)
    if [ "$status" == "C" ]; then
        echo "The nvt has completed."
        break
    elif [ "$status" == "R" ]; then
        echo "The nvt is still running..."
    fi
    sleep 60  # Adjust the sleep time (in seconds) based on your job length and scheduler configuration
done

# final MD 
cd ../../run/$1 
head -n 62 ../../nvt/$1/CONTCAR > POSCAR

# create vacncy 
sed -i '25,25d' POSCAR
sed -i '7,7d'   POSCAR
sed -i '7 i\    53' POSCAR

echo "submitting md run ...."
output=$(sbatch job.sh)
job_id=$(echo "$output" | awk '{print $4}')
echo "Job ID: $job_id"

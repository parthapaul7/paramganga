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
remove_vasp.sh <<< "yes"
output=$(sbatch debug.sh)
job_id=$(echo "$output" | awk '{print $4}')
echo "Job ID: $job_id"

# Wait for the first job to complete
echo "npt job is peding to start ..."
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
remove_vasp.sh <<< "yes"
output=$(sbatch debug.sh)
job_id=$(echo "$output" | awk '{print $4}')
echo "Job ID: $job_id"

echo "nvt job is pending to start ..."
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
remove_vasp.sh <<< "yes"
output=$(sbatch debug.sh)
job_id=$(echo "$output" | awk '{print $4}')
echo "Job ID: $job_id"

echo "md run is submitted and pending to start ..."


i=0
while true; do
    #put sleep for 57 minutes
    ((i++))
    while true; do
        status=$(check_job_status $job_id)
        if [ "$status" == "R" ]; then
	    echo "md run $i is started .."
            break
        fi
        sleep 30  # Adjust the sleep time (in seconds) based on your job length and scheduler configuration
    done

    sleep 3400

    status=$(check_job_status $job_id)
    if [ "$status" != "R" ]; then
        cat XDATCAR > ../../dumps/$1/XDATCAR$i
        cat OSZICAR > ../../dumps/$1/OSZICAR$i
        cat POSCAR  > ../../dumps/$1/POSCAR$i

        echo "some error or job closed. stopping run ... "
	exit 0
        break

    elif [ "$status" == "R" ]; then
        
        sleep 300
        # again make a job by concatting
        last_step=$(grep "T=" OSZICAR | tail -1 | grep -oP '\d+(?=\s+T=)')
        existing_nsw=$(grep -oP 'NSW *= *\K\d+' INCAR)

        # Subtract the desired amount (e.g., 50) from the last step number
        new_nsw=$((existing_nsw - last_step))

        # Modify the NSW parameter in the INCAR file
        sed -i "s/NSW *= *[0-9]*/NSW = $new_nsw/" INCAR

        cat XDATCAR > ../../dumps/$1/XDATCAR$i
        cat OSZICAR > ../../dumps/$1/OSZICAR$i
        cat POSCAR  > ../../dumps/$1/POSCAR$i
  
        \rm POSCAR
	cat CONTCAR > POSCAR

	remove_vasp.sh <<< "yes"
	
        output=$(sbatch debug.sh)
	job_id=$(echo "$output" | awk '{print $4}')
        echo "Job ID: $job_id"
    fi
done


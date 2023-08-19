#!/bin/bash


# final MD 
check_job_status() {
    local job_id=$1
    local status=$(qstat -f $job_id | awk '/job_state/{print $3}')
    echo "$status"
}


cd ./run/$1 

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
    ((i++))
    while true; do
        status=$(check_job_status $job_id)
        if [ "$status" == "R" ]; then
	    echo "md run $i is started .."
            break
        fi
        sleep 30  
    done

    #put sleep for 57 minutes
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

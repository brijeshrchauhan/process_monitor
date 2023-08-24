#!/bin/bash

#
# Script Name: restore_monitor.sh
# Description: A shell script designed to monitor the progress of a data restoration process. It calculates the estimated time of completion (ETA) based on data growth rate and provides real-time updates on the restore progress, helping administrators track restoration status efficiently.
# Author: Brijesh Chauhan (https://www.linkedin.com/in/brijesh-chauhan/)
# Date: August 22, 2023
#

# Define color escape codes
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

MAGENTA_BG='\033[0;45m'
BLACK_BG='\033[0;40m'
RED_BG='\033[0;41m'
GREEN_BG='\033[0;42m'
YELLOW_BG='\033[0;43m'
BLUE_BG='\033[0;44m'
MAGENTA_BG='\033[0;45m'
CYAN_BG='\033[0;46m'
WHITE_BG='\033[0;47m'

if [ "$#" -eq 3 ]; then
    # Parse and extract the values of the arguments
    for arg in "$@"; do
        if [[ "$arg" == --backup_file=* ]]; then
            backup_file="${arg#*=}"
        elif [[ "$arg" == --progress_interval=* ]]; then
            progress_interval="${arg#*=}"
	elif [[ "$arg" == --backup_type=* ]]; then
            backup_type="${arg#*=}"
        else
            echo -e "\n${RED}${MAGENTA_BG}During execution, an invalid selection was encountered.${NC}\n"
	    echo -e "${GREEN}${MAGENTA_BG}The acceptable choices are listed below.${NC}"
	    echo -e "\n\t${CYAN}--backup_file=/PATH/FILE_NAME${NC}"
            echo -e "\t${CYAN}--progress_interval=INTERVAL_IN_SECONDS${NC}"
            echo -e "\t${CYAN}--backup_type=mysqldump/mydumper${NC}\n"
            exit 1
        fi
    done

    # Check if all required arguments are provided
    if [ -z "$backup_file" ] || [ -z "$progress_interval" ] || [ -z "$backup_type" ]; then
       	echo -e "\n${RED}${MAGENTA_BG}During execution, an incorrect value was encountered.${NC}\n"
        echo -e "${GREEN}${MAGENTA_BG}The acceptable values are listed below.${NC}"
        echo -e "\n\t${CYAN}--backup_file=/PATH/FILE_NAME${NC}"
        echo -e "\t${CYAN}--progress_interval=INTERVAL_IN_SECONDS${NC}"
        echo -e "\t${CYAN}--backup_type=mysqldump/mydumper${NC}\n"
        exit 1;
    else
	if [ ! -e $backup_file ]; then
		echo -e "\n${RED}Backup $backup_file does not exist. Please check.${NC}\n"
		exit 1;
	fi

        if [[ "$backup_type" != "mysqldump" && "$backup_type" != "Mysqldump" && "$backup_type" != "mydumper" && "$backup_type" != "Mydumper" ]]; then
		echo -e "\n${RED}${MAGENTA_BG}Incorrect value for backup_type:${NC}"
		echo -e "\n${GREEN}${MAGENTA_BG}Valid backup_type:${NC}"
		echo -e "\n\t${CYAN}1. mysqldump${NC}"
		echo -e "\t${CYAN}2. mydumper${NC}\n"
		exit 1;
	fi

	if ! [[ "$progress_interval" =~ ^[0-9]+$ ]]; then
	        echo -e "\n${RED}Please provide a valid integer value for the progress_interval option.${NC}\n"
		exit 1;
	fi
    fi
else
    echo -e "\n${RED}USAGE: ./restore_progress.sh --backup_file=</full_path/file_name> --progress_interval=<interval_in_seconds> --backup_type=<mysqldump/mydumper>${NC}\n"
    exit 1
fi

get_restore_pids() {
    if [[ "$backup_type" = "mysqldump" || "$backup_type" = "Mysqldump" ]]; then
        pids=($(ps -ef | awk -F ' ' '{print $2 " " $8}' | grep -i mysql$ | cut -d ' ' -f1))
    elif [[ "$backup_type" = "mydumper" || "$backup_type" = "Mydumper" ]]; then
        pids=($(ps -ef | awk -F ' ' '{print $2 " " $8}' | grep -i myloader$ | cut -d ' ' -f1))
    else
        echo -e "\n${RED}Backup type is not valid${NC}"
        exit 1
    fi

    num_pids=${#pids[@]}

    if [[ $num_pids -eq 0 ]]; then
        echo -e "\n${RED}No restore process found. Please verify that restore is running.${NC}\n"
        exit 1
    elif [[ $num_pids -eq 1 ]]; then
        pid=${pids[0]}
    else
        echo -e "\n${YELLOW}Multiple $backup_type restore processes are currently active on the host. To monitor a specific process, select the option:${NC}\n"
        for ((i=0; i<num_pids; i++)); do
#            echo "$i. ${pids[$i]}"
	    ps_command=$(ps -p "${pids[$i]}" -o cmd=)
	    echo -e "${CYAN}Option $i: Process ${pids[$i]}${NC}\n"
	   # echo -e "${CYAN}COMMAND: ${pids[$i]}:${NC} ${GREEN}$ps_command${NC}\n"
	    echo -e "${MAGENTA}COMMAND: ${GREEN}$ps_command${NC}\n"
        done
        read -p "Enter the option number corresponding to the PID: " selection
        if [[ $selection -ge 0 && $selection -lt $num_pids ]]; then
            pid=("${pids[$selection]}")
        else
            echo -e "\n${RED}Invalid selection.${NC}"
            exit 1
        fi
    fi
#    echo -e "${GREEN}\nMonitoring progress of PIDs: ${pid[*]}${NC}\n"
}

get_restore_pids

file1="/proc/$pid/io"

if [ ! -e $file1 ] ; then
        echo -e "\n${RED}WARNING: It appears that the restore process is not running. Please verify by using the ps -ef command to check the status${NC}\n"
        exit 1;
fi

get_file_sizes() {
    size1=$(awk '/^rchar/ {print $2}' "$file1")

    if [[ "$backup_type" = "mydumper" || "$backup_type" = "Mydumper" ]]; then

	if [ -d $backup_file ]; then
		#num_of_dirs=`ls -l $backup_file *.sql* | grep -c "^d"`
		num_of_dirs=`find /root/mydumper_backup -name "*.sql" -type d | wc -l`
		if [[ $num_of_dirs > 1 ]]; then
			echo -e "\n${RED}Warning: The provided mydumper backup directory $backup_file is invalid. It contains multiple directories.${NC}\n"
			exit 1;
		else
		    	size2=$(find $backup_file -name "*.sql*" -type f -exec du -cb {} + | grep total$ | awk '{print $1}')
		fi
	else
		echo -e "\n${RED}Warning: The provided mydumper backup directory $backup_file is invalid. Please ensure you provide a valid mydumper backup directory\n${NC}"
		exit 1;
	fi
    elif [[ "$backup_type" = "mysqldump" || "$backup_type" = "Mysqldump" ]]; then
	if [ -f $backup_file ]; then
		size2=$(stat -c %s "$backup_file")
	else
		echo -e "\n${RED}Warning: The provided mysqldump backup file $backup_file is invalid. Please ensure you provide a valid mysqldump backup file\n${NC}"
		exit 1;
	fi
    else
	echo "\n${RED}Unable to locate the backup. Please check the option values.${NC}\n"
    fi
}

get_restore_speed() {

    if [ -f "$file1" ]; then
        io_bytes_read_new=$(awk '/^rchar/ {print $2}' "$file1")

        restore_speed=$((io_bytes_read_new - io_bytes_read))
	restore_speed_second=$((restore_speed/progress_interval))
	restore_speed_second_mb=$((restore_speed_second/(1024*1024)))
	formatted_restore_speed_second_mb=$(awk -v restore_speed=$restore_speed -v interval=$progress_interval 'BEGIN { printf "%.2f", restore_speed / (1024 * 1024 * interval) }')
#	formatted_restore_speed_second_mb=$(printf %.2f $restore_speed_second_mb)

	io_bytes_read_prev=$io_bytes_read_new

	remaining_size=$((size2 - io_bytes_read_new))

        eta_seconds=$((remaining_size / restore_speed_second))

        # Calculate ETA in HH:MM:SS format
        eta_hours=$(( eta_seconds / 3600))
	eta_minutes=$(( (eta_seconds % 3600) / 60 ))
	eta_seconds=$((eta_seconds % 60))

	formatted_eta=$(printf "%02d:%02d:%02d" "$eta_hours" "$eta_minutes" "$eta_seconds")

    fi

}

# Function to display the progress bar
function display_progress() {

    progress=$(awk "BEGIN {printf \"%.2f\", ((100*$size1)/$size2)}")
    local width=80   # Width of the progress bar
    local percent=$progress  # Progress percentage

    # Calculate the number of blocks to be filled based on the percentage
#    local num_blocks=$(echo "$percent * $width / 100" | bc -l)
     local num_blocks=$(awk -v p="$percent" -v w="$width" 'BEGIN { printf "%.0f", p * w / 100 }')

    # Create the progress bar
    local bar=$(printf "%0.s=" $(seq 1 "$num_blocks"))
    local spaces=$(printf "%0.s " $(seq 1 "$((width - num_blocks))"))

    # Display the progress bar and percentage
    echo -ne "\r${YELLOW}Progress: ${MAGENTA}[$((io_bytes_read/(1024*1024))) MiB]${NC} ${CYAN}[${bar}${spaces}]${NC} ${GREEN}${percent}%${NC}  ${MAGENTA}[$formatted_restore_speed_second_mb MiB/s]${NC}  ${GREEN}ETA: $formatted_eta${NC}"

}

# Main loop to continuously update the progress bar
while true; do
if [ -f $file1 ] ; then
    get_file_sizes
    get_restore_speed
    io_bytes_read=$io_bytes_read_prev
    display_progress
    sleep $progress_interval
else
    echo -e "\n"
    echo -e "\n${GREEN}Restore is completed. Please verify.${NC}\n"
    exit 0;
fi
done

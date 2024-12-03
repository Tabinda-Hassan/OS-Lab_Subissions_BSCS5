#!/bin/bash


RESET="\033[0m"
RED="\033[31m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
MAGENTA='\033[35m'




# Backup destination directory
backup_destination="./Backups"
temp_backup_folder="./Temp"
files_list="$temp_backup_folder/files_to_backup.txt"



# Define log file location
log_file="./backup_log.txt"



# FUNCTION TO LOG MESSAGES
log_message() {
    echo -e "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$log_file"
}




# FUNCTION TO CREATE TIMESTAMPED BACKUP FOLDER
create_backup_folder() {

    clear

    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_folder="$backup_destination/backup_$timestamp"
    mkdir -p "$backup_folder"  # Ensure folder exists
    export backup_folder  # Ensure it's available globally


    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    echo -e "${GREEN}\t================================================================${RESET}"
    echo -e "${GREEN}\t----------------- Creating Backup Destination! -----------------${RESET}"    
    echo -e "${GREEN}\t================================================================${RESET}"
    echo -e "\n"
    echo -e "\n"
     
        log_message "$(echo -e "${YELLOW}Created backup destination directory: $backup_folder${RESET}")"

    echo -e "\n"
    echo -e "\n"
    echo -e "${CYAN}-------------------------------------------------------------${RESET}"
    echo -e "\n"
    echo -e "\n"
}






# FUNCTION TO COPY FILES TO THE BACKUP DIRECTORY
copy_files() {
    
    if [ ! -f "$files_list" ] || [ ! -s "$files_list" ]; then
        echo -e "${RED}\n\tNo files were added for backup. Please add files first.${RESET}"
        return
    fi

    log_message "$(echo -e "${CYAN}----- Starting file copy to backup folder. -----\n\n${RESET}")"
    copied_any=false

    # Iterate over the files from the list and copy them
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            cp "$file" "$backup_folder/"
            log_message "File copied: $file"
            copied_any=true
        else
            log_message "File not found (skipped): $file"
        fi
    done < "$files_list"


    if [ "$copied_any" = true ]; then
	    log_message "$(echo -e "${GREEN}\n\n\t\t----- File copy completed with items added to backup. -----${RESET}")"
    else
        log_message "$(echo -e "${RED}\n\t\tNo files were copied.${RESET}")"
    fi
    
    echo "  "
    echo "  "
    echo -e "${CYAN}-------------------------------------------------------------------------------------${RESET}"
    echo "  "
    echo "  "
}




# FUNCTION TO DISPLAY BACKUP SIZE

display_backup_size() {
    # Use a more prominent separator
    echo -e "\n"
    echo -e "${CYAN}\t-------------------- Backup Size --------------------${RESET}"
    
    # Check if the backup folder exists
    if [ ! -d "$backup_folder" ]; then
        echo -e "${RED}\tError: Backup folder does not exist.${RESET}"
        return
    fi

   

    # Display the backup size with a nice format
    size=$(du -sh "$backup_folder" 2>/dev/null | cut -f1)


    if [ -z "$size" ]; then
        echo -e "${RED}\tError: Unable to calculate backup size.${RESET}"
    else
        echo -e "\n"
        echo -e "${YELLOW}\t   📦 Backup size: ${size}${RESET}"
    fi



    # Add some additional spacing for better clarity
    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    echo -e "${CYAN}---------------------------------------------------------------------------${RESET}"
    echo -e "${CYAN}===========================================================================${RESET}"
    echo -e "\n"
    echo -e "\n"

    read -p "$(echo -e "${GREEN}\tPress Enter to return to the main menu......${RESET}")" dummy
    
    sleep 1
    
    clear

}





# Function to add files to backup folder

add_files_for_backup() {
    clear

    mkdir -p "$temp_backup_folder"  # Ensure temp folder exists
    > "$files_list"  # Clear previous file list

    while true; do
        echo -e "\n"
        echo -e "\n"
        echo -e "\n"
        echo -e "\n"
        echo -e "${CYAN}\t Would you like to add a file to backup?${RESET}"
        echo -e "${CYAN}\t-----------------------------------------${RESET}"
        echo -e "\n"      
        echo -e "${GREEN}\t 1) Yes${RESET}"
        echo -e "${RED}\t 2) No${RESET}"
        echo -e "\n"
	read -p "$(echo -e "${CYAN}\tChoose your option (1/2): ${RESET}")" choice
	echo -e "\n${CYAN}\t\tSelect the file number to delete (or type 'done' to finish):${RESET}"
        echo -e "\n"

        case $choice in
        1)
            while true; do
		        

                read -p "$(echo -e "${YELLOW}\n\n\tEnter the name of the file to add to backup: ${RESET}")" file_name

		if [[ "$file_name" == "done" ]]; then
                    break
                fi

                if [[ -f "$file_name" ]]; then
                    if grep -q "^$file_name$" "$files_list"; then
                        echo -e "${BLUE}\n\t\tFile '$file_name' is already in the backup list.${RESET}"
                    else
                        echo "$file_name" >> "$files_list"
                        echo -e "${GREEN}\n\t\tFile '$file_name' added to the backup list.${RESET}"
                    fi
                else
                    echo -e "${RED}\n\t\tFile '$file_name' not found. Please check the name and try again.${RESET}"
                fi
            done


                if [ ! -f "$files_list" ] || [ ! -s "$files_list" ]; then
                     echo -e "${RED}\n\t\tNo files added for backup yet.${RESET}"
                     return
                fi
                     echo -e "${CYAN}\n\t\tFiles to be backed up:${RESET}"
                     cat "$files_list" | while IFS= read -r line; do
                            echo -e "\t\t$line"
			sleep 2    
              done
            sleep 2
	    clear
            ;;
	    
        2)
	    echo -e "\n"
	    echo -e "\n"
            echo -e "${GREEN}\t\t   Exiting the backup file selection....   ${RESET}"
	    echo -e "${GREEN}\t\t===========================================${RESET}"
	    sleep 2
            break
            ;;
        *)
            echo -e "${RED}\n\tInvalid choice. Please select 1 or 2.${RESET}"
            sleep 2
            clear
	    ;;
        esac
    done


    echo "   "
    echo -e "${CYAN}=========================================================================${RESET}"
    echo -e "${CYAN}-------------------------------------------------------------------------${RESET}"
    echo "   "
    clear
}










# FUNCTION TO DELETE FILES FROM BACKUP LIST
delete_files_from_backup() {
    clear

    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    echo -e "${CYAN}\t\t\t=======================================================${RESET}"
    echo -e "${CYAN}\t\t\t------------ Delete Files from Backup List ------------${RESET}"
    echo -e "${CYAN}\t\t\t=======================================================${RESET}"
    echo -e "\n"
    echo -e "\n"


    if [ ! -f "$files_list" ] || [ ! -s "$files_list" ]; then
        echo -e "${RED}\t\tNo files available to delete. Please add files first.${RESET}"
        return
    fi

    echo -e "${YELLOW}\tFiles currently in the backup list:${RESET}\n"
    nl "$files_list" # Display files with numbers for easy selection

    echo -e "\n${CYAN}\t\tSelect the file number to delete (or type 'done' to finish):${RESET}"

    while true; do
	echo -e "\n"
	echo -e "\n"
        read -p "$(echo -e "${GREEN}\t\tEnter file number to delete: ${RESET}")" file_num
        if [[ "$file_num" == "done" ]]; then
		sleep 1
		clear
            echo -e "\n"
            echo -e "\n"
	    echo -e "${GREEN}\t\t------ Deletion process completed! ------${RESET}"
	    echo -e "${GREEN}\t\t=========================================${RESET}"
            break
        fi

        if [[ "$file_num" =~ ^[0-9]+$ ]] && [ "$file_num" -ge 1 ] && [ "$file_num" -le $(wc -l < "$files_list") ]; then
            file_to_delete=$(sed -n "${file_num}p" "$files_list")
            sed -i "${file_num}d" "$files_list"
            echo -e "${RED}\n\t\tDeleted: $file_to_delete${RESET}"
        else
            echo -e "${RED}\n\t\tInvalid choice. Please enter a valid file number.${RESET}"
        fi
    done

    echo -e "\n"
    echo -e "\n"
    echo -e "${CYAN}\t\t-> Updated backup list: ${RESET}"
    echo -e "${CYAN}\t\t-----------------------------\n${RESET}"
    if [ -s "$files_list" ]; then
        nl "$files_list"  | while IFS= read -r line; do
        echo -e "\t\t$line"
     done
    else
        echo -e "${RED}\n\t\tNo files remaining in the backup list.${RESET}"
    fi


    echo -e "\n"
    echo -e "\n"
    echo -e "\n"
    echo -e "${CYAN}--------------------------------------------------------------------------${RESET}"
    echo -e "${CYAN}==========================================================================${RESET}"
    echo -e "\n"
    echo -e "\n"

    read -p "$(echo -e "${GREEN}\tPress Enter to return to the main menu......${RESET}")" dummy

    sleep 1
    clear 

}







# FUNCTION TO RESTORE FILES FROM BACKUP
restore_files() {
    clear
    echo -e "${CYAN}\n\t\tAvailable Backups:${RESET}"

    # List valid backup folders
    available_backups=$(ls "$backup_destination" 2>/dev/null)
    if [ -z "$available_backups" ]; then
        echo -e "${RED}\n\t\tNo backups found.${RESET}"
        return
    fi
    echo "$available_backups"

    # Prompt user to select a backup folder
    while true; do
        read -p "$(echo -e "${YELLOW}\n\t\tEnter the name of the backup folder to restore: ${RESET}")" restore_folder
        restore_path="$backup_destination/$restore_folder"

        if echo "$available_backups" | grep -qw "$restore_folder"; then
            read -p "$(echo -e "${YELLOW}\n\t\tEnter the directory to restore files to: ${RESET}")" restore_dir
            mkdir -p "$restore_dir"

            cp -r "$restore_path/"* "$restore_dir/"
            echo -e "${GREEN}\n\t\tFiles restored to: $restore_dir${RESET}"
            log_message "\n\tFiles restored from $restore_folder to $restore_dir"
            break
        else
            echo -e "${RED}\n\t\tInvalid backup folder. Please try again.${RESET}"
        fi
    done

    echo -e "\n"
    echo -e "\n"
    echo -e "${CYAN}-----------------------------------------------------------------------------${RESET}"
    echo -e "${CYAN}=============================================================================${RESET}"
    echo -e "\n"
    echo -e "\n"

    read -p "$(echo -e "${GREEN}\tPress Enter to return to the main menu......${RESET}")" dummy

    sleep 2
    clear



}







# MAIN SCRIPT EXECUTION


mkdir -p "$backup_destination"  # Ensure backup destination exists
mkdir -p "$temp_backup_folder"  # Ensure temp folder exists
> "$log_file"  # Initialize log file

clear
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "${YELLOW}\t\t\t====================================================================${RESET}"
echo -e "${YELLOW}\t\t\t|                                                                  |${RESET}"
echo -e "${YELLOW}\t\t\t|                                                                  |${RESET}"
echo -e "${YELLOW}\t\t\t|                    WELCOME TO THE BACKUP TOOL                    |${RESET}"
echo -e "${YELLOW}\t\t\t|                                                                  |${RESET}"
echo -e "${YELLOW}\t\t\t|                                                                  |${RESET}"
echo -e "${YELLOW}\t\t\t|         A reliable solution for safeguarding your files          |${RESET}"
echo -e "${YELLOW}\t\t\t|           Easily backup, manage, and secure your data            |${RESET}"
echo -e "${YELLOW}\t\t\t|                                                                  |${RESET}"
echo -e "${YELLOW}\t\t\t|                                                                  |${RESET}"
echo -e "${YELLOW}\t\t\t===================================================================${RESET}"
echo -e "\n"
echo -e "\n"
echo -e "\n"

sleep 3

clear


echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "${GREEN}\t\t\t                Initializing Backup Process..........${RESET}"
echo "   "
echo -e "${YELLOW}\t\t\t==================================================================${RESET}"
echo -e "${YELLOW}\t\t\t..................................................................${RESET}"

sleep 3

clear



# Menu options
while true; do

	clear
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "\n"
echo -e "${GREEN}\t\t*******************************************************${RESET}"
echo -e "${GREEN}\t\t-------------------------------------------------------${RESET}"
echo -e "${GREEN}\t\t             Welcome to the Backup Utility             ${RESET}"
echo -e "${GREEN}\t\t-------------------------------------------------------${RESET}"
echo -e "${GREEN}\t\t*******************************************************${RESET}"


    echo -e "\n"
    echo -e "\n"
    echo -e "${CYAN}\t\t     ========================================${RESET}"
    echo -e "${CYAN}\t\t     |               Main Menu              |${RESET}"
    echo -e "${CYAN}\t\t     ========================================${RESET}"
    echo -e "\n"
    echo -e "${YELLOW}\t\t\t1) Add files to backup${RESET}"
    echo -e "${YELLOW}\t\t\t2) Start backup${RESET}"
    echo -e "${YELLOW}\t\t\t3) Delete files from backup${RESET}"
    echo -e "${YELLOW}\t\t\t4) Restore Files${RESET}"
    echo -e "${YELLOW}\t\t\t5) Exit${RESET}"
    echo -e "\n"
    read -p "$(echo -e "${GREEN}\t\t\tEnter your choice: ${RESET}")" choice
    echo -e "\n"

    case $choice in
    1)
        add_files_for_backup
        ;;
    2)
        create_backup_folder
        copy_files
        display_backup_size
       # display_files_to_backup
        ;;
    3)
	delete_files_from_backup
        ;;
    4)
        restore_files
        ;;
    5)
	    clear
        echo -e "\n"
	echo -e "\n"
	echo -e "\n"
	echo -e "\n"
	echo -e "${GREEN}\t\t\t================================================================${RESET}"
        echo -e "${GREEN}\t\t\t---------------- Backup completed successfully! ----------------${RESET}"
        echo -e "${GREEN}\t\t\t================================================================${RESET}"
	echo -e "\n"
	echo -e "\n"
        echo -e "${GREEN}\t\t\t\t---------- Exiting. Goodbye! ----------${RESET}"
        echo -e "\n"
	echo -e "\n"
	echo -e "\n"
	exit 0
        ;;
    *)
        echo -e "\n"
        echo -e "${RED}\t\t\tInvalid choice. Please select a valid option.${RESET}"
	sleep 2
	clear
        ;;
    esac
done













# Restore Monitor Script

## Description

**restore_monitor.sh** is a shell script designed to monitor the progress of a data restoration process. It calculates the estimated time of completion (ETA) based on data growth rate and provides real-time updates on the restore progress, helping administrators track restoration status efficiently.

## Author

- Author: Brijesh Chauhan
- Date: August 22, 2023

## Usage

To use the script, follow these steps:

1. Open a terminal.
2. Run the script using the following command, replacing the placeholders with your own values:
   
   ```bash
   ./restore_monitor.sh --backup_file=</full_path/file_name> --progress_interval=<interval_in_seconds> --backup_type=<mysqldump/mydumper>

Replace the placeholders as follows:

    --backup_file: The full path to the backup file or directory.
    --progress_interval: The interval in seconds for progress updates.
    --backup_type: The backup type, either mysqldump or mydumper.

    The script will continuously display the progress of the restoration process, including the progress bar, percentage, current speed, and estimated time of completion (ETA).

## Important Notes

    Ensure you have the necessary permissions to execute the script and access the backup file or directory.
    The script is designed to work with MySQL backups created using mysqldump or mydumper.

## Example

Here's an example of how to use the script:
```
./restore_monitor.sh --backup_file=/path/to/backup/directory --progress_interval=10 --backup_type=mydumper
```

In this example, the script will monitor the restoration progress of the mydumper backup located in /path/to/backup/directory, with progress updates every 10 seconds.

## Disclaimer

This script is provided as-is without any warranties. Use it at your own risk.

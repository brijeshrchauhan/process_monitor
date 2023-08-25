# Restore Monitor Script

## Description

The **Restore Monitor Script** is a powerful script designed to monitor the progress of MySQL backup restoration using either mysqldump or mydumper backup files. This script provides an easy-to-use and automated way to track the restoration progress, calculates the estimated time of completion (ETA) based on data growth rate and provides real-time updates on the restore progress, making it a valuable tool for administrators who need to restore large-scale MySQL backups and want to keep track of the progress.

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

The script will continuously display the progress of the restoration process, including the amount of data restored, progress bar, percentage, current speed, and estimated time of completion (ETA).

## Features

1. **Flexible Backup Type Support:**
   The script supports two popular backup types - mysqldump and mydumper. Users can choose their preferred backup type by providing the 'backup_type' argument during script execution.

2. **Customizable Progress Update Interval:**
   The script allows users to set the 'progress_interval' argument to define the time interval (in seconds) at which the restoration progress will be displayed. This gives users the flexibility to monitor progress as frequently as needed.

3. **Easy Backup File Location Input:**
   The 'backup_file' argument allows users to specify the location of the backup file used for restoration. The script automatically detects the restore process associated with the provided backup file, simplifying the monitoring process.

4. **Intelligent Process Detection:**
   The script intelligently detects the MySQL restore process running for the specified backup file. It analyzes the system's active processes and identifies the restore process for accurate monitoring.

5. **Real-Time Progress Updates:**
   Once the restore process is detected, the script continuously monitors its progress. At each interval specified by 'progress_interval', the script displays the progress of the restoration process, including the amount of data restored, progress bar, percentage, current speed, and estimated time of completion (ETA).

6. **User-Friendly Output:**
   The script presents the progress updates in a clear and concise manner, making it easy for users to understand and track the restoration progress.

7. **Utilizing Unexplored Monitoring Options:**
   One of the unique advantages of this script is that it addresses the lack of built-in monitoring tools for restoring mysqldump and mydumper backups. By leveraging the Linux native I/O statistics and custom process detection, the script provides an efficient solution for monitoring the restore process.

## Important Notes

Ensure you have the necessary permissions to execute the script and access the backup file or directory.
The script is designed to work with MySQL backups created using mysqldump or mydumper.

## Example Output

Here is an example output of running the script:

```bash
./restore_monitor.sh --backup_file=/path/to/backup/backup.sql --progress_interval=5 --backup_type=mysqldump
Progress: [1119 MiB] [========================================                                        ] 50.06%  [11.27 MiB/s]  ETA: 00:10:26
```
In this example output, the script restore_monitor.sh is executed with the provided parameters. The script displays real-time progress information of a mysqldump restoration process. The progress bar indicates that 1119 MB of data is restored, 50.06% of the restoration is completed, with a current speed of 11.27 MiB/s. The estimated time of completion (ETA) is 00:10:26 (HH:MM:SS).

## Note

The estimated time to restore (ETA) provided here, is assumed to be a consistent restore speed. However, it's important to note that the actual restore speed can vary due to a multitude of factors. Factors such as system load, disk I/O contention, network congestion, disk caching, and other variables can influence the restore speed.

As a result, the ETA presented should be considered as a rough estimate and not an exact prediction. The actual time taken to complete the restore process may be longer or shorter than the calculated ETA. It's recommended to use the calculated ETA as a general guideline while keeping in mind the potential variability in restore speed due to these factors.

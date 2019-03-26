# backup-scripts

SQL Server Express does not support automated backups, so this script is a basic workaround for that limitation. 

When this script runs, it makes a backup of the master, model, and msdb system databases, as well as any other databases it can find on the host, and saves them to the $backup_folder directory. 

It then automatically looks through the $backup_folder to purge any files that are older than the $retention_period.

It is *very important* that you change the $backup_folder and $retention_period variables to whatever settings suit your setup.

_Warning:_ This script automatically deletes *any* file in the $backup_folder that is older than the $retention_period, even if it's completely unrelated to the backups, so don't store anything else in there!

To have this script run on a recurring basis, you can create a scheduled task by specifying `powershell -file [backupscript location]` as a program to run. 

The account that runs the script *must* have permissions to perform a backup on the database. Ideally, it should run as an unprivileged account with only the `db_backupoperator` role assigned, see https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2012/ms187510%28v%3dsql.110%29#security

This script has only been tested on Server 2012 R2, and at minimum requires PowerShell version 4 to run.
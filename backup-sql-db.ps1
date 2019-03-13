# Backup-SQL-DB
#
# Automatically backs up SQL databases and purges old backups 

#Requires -Modules SQLPS
#Requires -Version 4

# Global Variables
$instances = Get-ChildItem "SQLSERVER:\SQL\$(hostname)"
$backup_folder = "C:\z-backups"

# Functions
#
# Backup-SqlDatabase-AsDatedFile
# Creates backup files in a year-month-day-hour-minute format in the predefined backup folder
function Backup-SqlDatabase-AsDatedFile ($server_instance, $database) {
    Backup-SqlDatabase -Database $database -ServerInstance "$server_instance.Name" -BackupAction Database -BackupFile "$backup_folder\$server_instance.InstanceName-$database-$(Get-Date -UFormat `"%Y-%m-%d-%H-%M`")"
}

ForEach ($instance in $instances) {
    # Back up system DBs msdb, master, and model as refrenced in link below
    # https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2012/ms190190(v%3dsql.110) 
    Backup-SqlDatabase-AsDatedFile($instance, "master")
    Backup-SqlDatabase-AsDatedFile($instance, "model")
    Backup-SqlDatabase-AsDatedFile($instance, "msdb")
    
    # Backup any instances DBs
    Get-ChildItem "SQLSERVER:\SQL\$instance.Name" | ForEach-Object {
        Backup-SqlDatabase-AsDatedFile(
    }
}

# Reference articles
#
# Back up full database in general, includes PowerShell snippet
# https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2012/ms186289(v%3dsql.110)
#
# Backup-SqlDatabase help page
# https://docs.microsoft.com/en-us/powershell/module/sqlserver/backup-sqldatabase?view=sqlserver-ps
#
# Includes PS snippet for purging old backups
# https://blog.sqlauthority.com/2018/04/02/sql-server-powershell-script-delete-old-backup-files-in-sql-express/
#
# Info about get-childitem in the sqlps context
# Fun fact: get-childitem -force is necessary to see system databases 
# https://docs.microsoft.com/en-us/sql/powershell/navigate-sql-server-powershell-paths?view=sql-server-2014

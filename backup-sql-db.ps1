# Backup-SQL-DB
#
# Automatically backs up SQL databases and purges old backups 

#Requires -Modules SQLPS
#Requires -Version 4

# Global Variables
$instances = Get-ChildItem "SQLSERVER:\SQL\$(hostname)"
$backup_folder = "C:\z-backups"
$retention_period = New-Object -TypeName System.TimeSpan -ArgumentList 7,0,0,0  # Retention period for how long backups are to be kept, specified as days,hours,minutes,seconds in the -ArgumentList paramter

# Functions
#
# Backup-SqlDatabase-AsDatedFile
# Creates backup files in a year-month-day-hour-minute format in the predefined backup folder
function Backup-SqlDatabase-AsDatedFile ($ServerInstance, $database) {
    Backup-SqlDatabase -Database $database -ServerInstance "$ServerInstance.Name" -BackupAction Database -BackupFile "$backup_folder\$($ServerInstance.InstanceName)-$database-$(Get-Date -UFormat `"%Y-%m-%d-%H-%M`")"
}

# Backup all databases
ForEach ($instance in $instances) {
    # Back up system DBs msdb, master, and model as refrenced in link below
    # https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2012/ms190190(v%3dsql.110) 
    Backup-SqlDatabase-AsDatedFile -ServerInstance $instance -Database "master"
    Backup-SqlDatabase-AsDatedFile -ServerInstance $instance -Database "model"
    Backup-SqlDatabase-AsDatedFile -ServerInstance $instance -Database "msdb"
    
    # Backup any instances DBs
    ForEach ($database in Get-ChildItem "SQLSERVER:\SQL\$($instance.Name)") {
        Backup-SqlDatabase-AsDatedFile -ServerInstance $instance -Database $database
    }
}

# Purge backups 
Get-ChildItem -Path $backup_folder | 
    Where-Object { $_.LastWriteTime -lt $(Get-Date).Subtract($retention_period) } | 
        Remove-Item

# Reference articles
#
# Back up full database in general, includes PowerShell snippet
# https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2012/ms186289(v%3dsql.110)
# https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2012/ms187510(v%3dsql.110)#using-powershell
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
#
# TimeSpan constructor
# https://docs.microsoft.com/en-us/dotnet/api/system.timespan.-ctor?view=netframework-4.7.2#System_TimeSpan__ctor_System_Int32_System_Int32_System_Int32_System_Int32_
#
# DateTime subtract timespan
# https://docs.microsoft.com/en-us/dotnet/api/system.datetime.subtract?view=netframework-4.7.2#System_DateTime_Subtract_System_TimeSpan_
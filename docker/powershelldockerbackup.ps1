# PowerShell Backup Script for Docker Containers
# 2019-9-30 Daphne Lundquist
Write-Host "[PowerShell Backup Script for Docker Containers]"

# Get current container IDs
$CONT1ID = docker ps -aqf "name=asdf-docker_asdf_1"
$CONT2ID = docker ps -aqf "name=wasd-docker_redis_1"
Write-Host $CONT1ID
Write-Host $CONT2ID

# Get current time
$DST = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
$DST = $DST.ToLower()
$LOGFILE = "logfile" + $DST + ".txt"
# Build filenames to save to filesystem
$CONT1SAVESTR = $CONT1ID + $DST
$CONT2SAVESTR = $CONT2ID + $DST

$CONT1WRITE = "CONT1ID is: " + $CONT1ID
$CONT2WRITE = "CONT2ID is: " + $CONT2ID
Add-Content $LOGFILE $CONT1WRITE
Add-Content $LOGFILE $CONT2WRITE
Add-Content $LOGFILE $DST

# Make commits for the containers
# ex: docker commit -p <containerID> <commitname>
docker commit -p $CONT1ID $CONT1SAVESTR
docker commit -p $CONT2ID $CONT2SAVESTR

# Save the commits to .tar files on the filesystem
$CONT1TAR = $CONT1SAVESTR + ".tar"
$CONT2TAR = $CONT2SAVESTR + ".tar"
#ex: docker save -o <file.tar> <commitname>
docker save -o $CONT1TAR $CONT1SAVESTR
docker save -o $CONT2TAR $CONT2SAVESTR

#$CONT1TAR = "test1.tar"
#$CONT2TAR = "test2.tar"

# Copy .tar files to network share (formatted for Windows)
#$TimeStamp = get-date -f yyyyMMddhhmm
$DESTINATION = "\\ACOMPUTER\folder\container_backup"
New-Item -ItemType directory -Path $DESTINATION -Force
$SRC = "C:\container_backup\" + $CONT1TAR
Copy-Item -Path $SRC -Destination $DESTINATION -Force
$SRC = "C:\container_backup\" + $CONT2TAR
Copy-Item -Path $SRC -Destination $DESTINATION -Force
$SRC = "C:\container_backup\" + $LOGFILE
Copy-Item -Path $SRC -Destination $DESTINATION -Force
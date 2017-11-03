#!/bin/bash -eu

# script to perform the remote backup
do_bkup() {
# execute the next script remotely
ssh mayeur.be@ssh.mayeur.be 'bash -s' << 'ENDSSH'

    # set the directory to backup
    dir="/www/"
    # set the directory where to store the backup files
    bkdir="/home/mayeur.be"
    # get the current date
    NOW=$(date +"%Y%m%d")
    # ... and current day
    DAY=$(date +%d)

    # create a full 'level0' backup on the first of the month
    if [ ${DAY} -eq 01 ]
    then
        LEV="--level=0"
        SUFFIX="_0"
        # remove any previous backup files, as we create a new full backup
        rm ${bkdir}/*.tgz
    else
        LEV=""
        SUFFIX=""
    fi

   cd ${dir}; tar -g ${bkdir}/incr.snar ${LEV} -pcf - . | gzip > ${bkdir}/$NOW_www.mayeur.be$SUFFIX.tgz 

ENDSSH

# copy the backup files from the web host to the local nas server
sudo rsync -a mayeur.be@ssh.mayeur.be:~/* /mnt/nas/mayeur.be
}

# mount the nas server folder
do_mount() {
    sudo mount -t cifs  //192.168.0.16/Other /mnt/nas -o username=admin,password=Bretzel58,uid=root,file_mode=0777,dom=WORKGROUP
}

# clean up actions - umount files
cleanup() {
    sudo umount /mnt/nas
}

# main program
trap cleanup EXIT INT TERM
do_mount
do_bkup


#!/bin/bash -eu

do_bkup() {
ssh mayeur.be@ssh.mayeur.be 'bash -s' << 'ENDSSH'

dir="/www/"
bkdir="/home/mayeur.be"
NOW=$(date +"%Y%m%d")
DAY=$(date +%d)
if [ ${DAY} -eq 01 ]
then
    LEV="--level=0"
    SUFFIX="_0"
else
    LEV=""
    SUFFIX=""
fi

send_data(){
    cd ${dir}; tar -g ${bkdir}/incr.snar ${LEV} -pcf - . | gzip > ${bkdir}/www.mayeur.be$SUFFIX_$NOW.tgz 
}

send_data

ENDSSH

sudo rsync -a mayeur.be@ssh.mayeur.be:~/* /mnt/nas/mayeur.be
}

do_mount() {
    sudo mount -t cifs  //192.168.0.16/Other /mnt/nas -o username=admin,password=Bretzel58,uid=root,file_mode=0777,dom=WORKGROUP
}

cleanup() {
    sudo umount /mnt/nas
}

trap cleanup EXIT INT TERM
do_mount
do_bkup

